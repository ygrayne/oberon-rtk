"""
elftestengine -- Structural ELF/DWARF test engine for Oberon RTK programs.
--
Runs inside GDB (Python-enabled). Receives a list of procedure dicts from
a generated test script (produced by gen-elf-test), sets breakpoints at
post-prologue addresses, and checks that all params/locals are present
and accessible in GDB.
Level 1 structural test: checks presence and accessibility of DWARF debug
info. Does NOT check value correctness.
This module is imported by per-project generated test scripts. It is not
run directly.
Supports JLink GDB Server and OpenOCD. Server type is auto-detected at
connect time. JLink uses flash breakpoints (all set at once). OpenOCD
uses hardware breakpoint rotation (limited by Cortex-M FPB slots).
The GDB server host:port can be overridden at runtime via the
RTK_GDB_HOST environment variable.
--
Usage:
    Public API:
        run_test(procedures, elf_path, host, max_hits, continue_timeout)
            -> (TestResult, hit_count, tested_count)
        print_report(result, procedures, hit_count, tested_count, elf_path)
            Print plain text report to console.
        format_report(result, procedures, hit_count, tested_count, elf_path)
            Return plain text report as string.
        main(procedures, elf_path, host, max_hits, report_dir, script_name)
            Run test, print/write report, quit GDB.
--
Copyright (c) 2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""
import random
import re
import time
_MAX_PASSES = 40
_QUICK_TIMEOUT = 1
_EMPTY_PASS_LIMIT = 3
class TestResult:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.skipped = 0
        self.errors = []
        self.proc_results = {}
    def record(self, proc_name, check_type, var_name, passed, detail=''):
        if proc_name not in self.proc_results:
            self.proc_results[proc_name] = {'tested': True, 'checks': []}
        status = 'PASS' if passed else 'FAIL'
        self.proc_results[proc_name]['checks'].append(
            (check_type, var_name, status, detail))
        if passed:
            self.passed += 1
        else:
            self.failed += 1
            self.errors.append(
                f"{proc_name}: {check_type} {var_name} - {detail}")
    def skip_proc(self, proc_name):
        self.skipped += 1
        if proc_name not in self.proc_results:
            self.proc_results[proc_name] = {'tested': False, 'checks': []}
def gdb_execute_capture(cmd):
    import gdb
    try:
        return gdb.execute(cmd, to_string=True)
    except gdb.error as e:
        return f"ERROR: {e}"
def parse_info_output(output):
    result = {}
    if output is None:
        return result
    for line in output.strip().splitlines():
        line = line.strip()
        if not line or line == 'No arguments.' or line == 'No locals.':
            continue
        m = re.match(r'^(\w+)\s*=\s*(.*)', line)
        if m:
            name = m.group(1)
            value = m.group(2).strip()
            accessible = not (
                'Cannot access memory' in value
                or '<error' in value
                or 'optimized out' in value
            )
            result[name] = (accessible, value)
    return result
def _interrupt_after(seconds):
    import gdb
    import threading
    def _do_interrupt():
        try:
            gdb.post_event(lambda: gdb.execute('interrupt'))
        except Exception:
            pass
    timer = threading.Timer(seconds, _do_interrupt)
    timer.daemon = True
    timer.start()
    return timer
def _detect_server():
    import gdb
    try:
        gdb.execute('monitor flash breakpoints = 1', to_string=True)
        return 'JLink'
    except gdb.error:
        return 'OpenOCD'
def _reset_halt(server):
    import gdb
    if server == 'JLink':
        gdb.execute('monitor reset', to_string=True)
    else:
        gdb.execute('monitor reset halt', to_string=True)
def _query_hw_bp_limit():
    import gdb
    try:
        out = gdb.execute('print/x *(unsigned int*)0xE0002000',
                          to_string=True)
        fpb_ctrl = int(out.split('=')[1].strip(), 16)
        num_code_lo = (fpb_ctrl >> 4) & 0xF
        num_code_hi = (fpb_ctrl >> 12) & 0x7
        num_bp = num_code_lo | (num_code_hi << 4)
        if num_bp > 0:
            return num_bp
    except (gdb.error, ValueError, IndexError):
        pass
    return 4
def _test_procedure(proc, result):
    full_name = proc['full_name']
    if proc['params']:
        args_output = gdb_execute_capture('info args')
        args_dict = parse_info_output(args_output)
        for param in proc['params']:
            pname = param['name']
            if pname in args_dict:
                accessible, value = args_dict[pname]
                result.record(full_name, 'param_present', pname, True)
                result.record(full_name, 'param_access', pname,
                              accessible, value if not accessible else '')
            else:
                result.record(full_name, 'param_present', pname,
                              False, 'missing from info args')
    if proc['locals']:
        locals_output = gdb_execute_capture('info locals')
        locals_dict = parse_info_output(locals_output)
        for local in proc['locals']:
            lname = local['name']
            if lname in locals_dict:
                accessible, value = locals_dict[lname]
                result.record(full_name, 'local_present', lname, True)
                result.record(full_name, 'local_access', lname,
                              accessible,
                              value if not accessible else '')
            else:
                result.record(full_name, 'local_present', lname,
                              False, 'missing from info locals')
def _run_jlink(procedures, server, max_hits, continue_timeout):
    import gdb
    result = TestResult()
    tested_set = set()
    bp_num = {}
    bp_count = 0
    for proc in procedures:
        out = gdb.execute(f"break *0x{proc['bp_addr']:08X}", to_string=True)
        bp_count += 1
        m = re.search(r'Breakpoint\s+(\d+)', out)
        if m:
            bp_num[proc['bp_addr']] = int(m.group(1))
    print(f"Set {bp_count} breakpoints")
    _reset_halt(server)
    time.sleep(0.1)
    print(f"Starting test (max {max_hits} hits)...")
    hit_count = 0
    all_procs_needing_test = set()
    for proc in procedures:
        if not proc['is_init'] and (proc['params'] or proc['locals']):
            all_procs_needing_test.add(proc['full_name'])
    bp_addrs = set(proc['bp_addr'] for proc in procedures)
    bp_to_proc = {proc['bp_addr']: proc for proc in procedures}
    while hit_count < max_hits:
        if all_procs_needing_test and tested_set >= all_procs_needing_test:
            print(f"All testable procedures tested after {hit_count} hits")
            break
        timer = _interrupt_after(continue_timeout)
        try:
            gdb.execute('continue', to_string=True)
        except gdb.error as e:
            timer.cancel()
            print(f"Target error: {e}")
            break
        timer.cancel()
        try:
            pc_output = gdb.execute('print/x $pc', to_string=True)
            m = re.search(r'0x([0-9a-fA-F]+)', pc_output)
            if not m:
                continue
            pc = int(m.group(1), 16)
        except gdb.error:
            continue
        if pc not in bp_addrs:
            print(f"No breakpoint hit (stopped at 0x{pc:08X}), "
                  f"ending after {hit_count} hits")
            break
        hit_count += 1
        proc = bp_to_proc.get(pc)
        if proc is None:
            continue
        full_name = proc['full_name']
        if proc['is_init']:
            bn = bp_num.get(proc['bp_addr'])
            if bn is not None:
                gdb.execute(f'delete {bn}', to_string=True)
            continue
        if full_name in tested_set:
            continue
        tested_set.add(full_name)
        _test_procedure(proc, result)
        bn = bp_num.get(proc['bp_addr'])
        if bn is not None:
            gdb.execute(f'delete {bn}', to_string=True)
        if hit_count % 50 == 0:
            print(f"  ... {hit_count} hits, "
                  f"{len(tested_set)} procedures tested")
    for proc in procedures:
        if proc['full_name'] not in tested_set and not proc['is_init']:
            if proc['params'] or proc['locals']:
                result.skip_proc(proc['full_name'])
    return result, hit_count, len(tested_set)
def _run_openocd(procedures, server, max_hits, continue_timeout):
    import gdb
    result = TestResult()
    tested_set = set()
    hit_count = 0
    bp_to_proc = {p['bp_addr']: p for p in procedures}
    all_needing_test = set(
        p['full_name'] for p in procedures
        if not p['is_init'] and (p['params'] or p['locals']))
    if not all_needing_test:
        for proc in procedures:
            if not proc['is_init'] and (proc['params'] or proc['locals']):
                result.skip_proc(proc['full_name'])
        return result, 0, 0
    max_hbp = _query_hw_bp_limit()
    print(f"FPB: {max_hbp} hardware breakpoint comparators")
    active = {}
    def _set_hbp(addr):
        out = gdb.execute(f'hbreak *0x{addr:08X}', to_string=True)
        m = re.search(r'(?:Hardware assisted b|B)reakpoint\s+(\d+)', out)
        if m:
            active[addr] = int(m.group(1))
    def _delete_hbp(addr):
        if addr in active:
            gdb.execute(f'delete {active[addr]}', to_string=True)
            del active[addr]
    def _clear_all():
        for addr in list(active):
            _delete_hbp(addr)
    def _fill(candidates):
        while len(active) < max_hbp and candidates:
            _set_hbp(candidates.pop(0))
    empty_passes = 0
    for pass_num in range(_MAX_PASSES):
        if tested_set >= all_needing_test:
            break
        candidates = [p['bp_addr'] for p in procedures
                      if not p['is_init']
                      and (p['params'] or p['locals'])
                      and p['full_name'] not in tested_set]
        if not candidates:
            break
        random.shuffle(candidates)
        _clear_all()
        _fill(candidates)
        remaining = len(active) + len(candidates)
        print(f"Pass {pass_num + 1}: {remaining} remaining, "
              f"{len(active)} active HW breakpoints")
        _reset_halt(server)
        time.sleep(0.1)
        tested_before = len(tested_set)
        got_hit = False
        while hit_count < max_hits:
            if tested_set >= all_needing_test:
                break
            if not active:
                break
            timeout = _QUICK_TIMEOUT if got_hit else continue_timeout
            timer = _interrupt_after(timeout)
            try:
                gdb.execute('continue', to_string=True)
            except gdb.error as e:
                timer.cancel()
                print(f"Target error: {e}")
                break
            timer.cancel()
            try:
                pc_output = gdb.execute('print/x $pc', to_string=True)
                m = re.search(r'0x([0-9a-fA-F]+)', pc_output)
                if not m:
                    continue
                pc = int(m.group(1), 16)
            except gdb.error:
                continue
            if pc not in active:
                break
            got_hit = True
            hit_count += 1
            proc = bp_to_proc.get(pc)
            _delete_hbp(pc)
            if proc and proc['full_name'] not in tested_set:
                tested_set.add(proc['full_name'])
                _test_procedure(proc, result)
            _fill(candidates)
            if hit_count % 50 == 0:
                print(f"  ... {hit_count} hits, "
                      f"{len(tested_set)} procedures tested")
        tested_this_pass = len(tested_set) - tested_before
        if tested_this_pass == 0:
            empty_passes += 1
            if empty_passes >= _EMPTY_PASS_LIMIT:
                print(f"  no new procedures in {empty_passes} consecutive "
                      f"passes, stopping")
                break
        else:
            empty_passes = 0
    _clear_all()
    for proc in procedures:
        if proc['full_name'] not in tested_set and not proc['is_init']:
            if proc['params'] or proc['locals']:
                result.skip_proc(proc['full_name'])
    return result, hit_count, len(tested_set)
def run_test(procedures, elf_path, host='localhost:3333',
             max_hits=500, continue_timeout=10):
    import gdb
    gdb.execute('set confirm off', to_string=True)
    gdb.execute('set pagination off', to_string=True)
    gdb.execute('set suppress-cli-notifications on', to_string=True)
    gdb.execute(f'file {elf_path}', to_string=True)
    gdb.execute(f'target remote {host}', to_string=True)
    server = _detect_server()
    print(f"Server: {server}")
    _reset_halt(server)
    gdb.execute('load', to_string=True)
    if server == 'JLink':
        return _run_jlink(procedures, server, max_hits, continue_timeout)
    else:
        return _run_openocd(procedures, server, max_hits, continue_timeout)
def print_report(result, procedures, hit_count, tested_count, elf_path):
    print(format_report(result, procedures, hit_count, tested_count,
                        elf_path))
def format_report(result, procedures, hit_count, tested_count, elf_path):
    total_procs = len(procedures)
    init_procs = sum(1 for p in procedures if p['is_init'])
    testable = sum(1 for p in procedures
                   if not p['is_init'] and (p['params'] or p['locals']))
    sep = '=' * 64
    lines = [
        sep,
        "Structural ELF Test Report",
        sep,
        f"  ELF:   {elf_path}",
        f"  Date:  {time.strftime('%Y-%m-%d %H:%M:%S')}",
        f"  Procs: {total_procs} total, {init_procs} init, "
        f"{testable} testable",
        f"  Hits:  {hit_count}",
        f"  Tested: {tested_count}",
        f"  PASS:  {result.passed}",
        f"  FAIL:  {result.failed}",
        f"  SKIP:  {result.skipped}",
        '',
    ]
    if result.errors:
        lines.append("FAILURES")
        lines.append('-' * 40)
        for err in result.errors:
            lines.append(f"  FAIL: {err}")
        lines.append('')
    passed_procs = []
    for proc in procedures:
        fn = proc['full_name']
        if proc['is_init']:
            continue
        if not proc['params'] and not proc['locals']:
            continue
        pr = result.proc_results.get(fn)
        if pr is None or not pr['tested']:
            continue
        fails = [c for c in pr['checks'] if c[2] == 'FAIL']
        if not fails:
            passed_procs.append(fn)
    if passed_procs:
        lines.append(f"PASSED ({len(passed_procs)} procedures)")
        lines.append('-' * 40)
        for fn in passed_procs:
            lines.append(f"  {fn}")
        lines.append('')
    skipped_procs = [p['full_name'] for p in procedures
                     if p['full_name'] not in result.proc_results
                     and not p['is_init']
                     and (p['params'] or p['locals'])]
    if skipped_procs:
        lines.append(f"SKIPPED ({len(skipped_procs)} procedures never called)")
        lines.append('-' * 40)
        for fn in sorted(skipped_procs):
            lines.append(f"  {fn}")
        lines.append('')
    if result.failed == 0:
        lines.append("RESULT: ALL CHECKS PASSED")
    else:
        lines.append(f"RESULT: {result.failed} FAILURES")
    lines.append('')
    return '\n'.join(lines)
def main(procedures, elf_path, host='localhost:3333', max_hits=500,
         continue_timeout=10, report_dir=None, script_name='elf-test'):
    import gdb
    import os
    env_host = os.environ.get('RTK_GDB_HOST')
    if env_host:
        host = env_host
    result, hit_count, tested_count = run_test(
        procedures, elf_path, host, max_hits, continue_timeout)
    print()
    print_report(result, procedures, hit_count, tested_count, elf_path)
    if report_dir is None:
        script_dir = os.path.dirname(os.path.abspath(
            gdb.execute('show script', to_string=True).split('"')[1]
            if False else __file__))
        report_dir = os.path.join(os.path.dirname(script_dir), 'reports')
    os.makedirs(report_dir, exist_ok=True)
    report_name = script_name + f'-report-{time.strftime("%Y%m%d-%H%M%S")}.txt'
    report_path = os.path.join(report_dir, report_name)
    report_text = format_report(
        result, procedures, hit_count, tested_count, elf_path)
    with open(report_path, 'w') as f:
        f.write(report_text)
    print(f"Report: {report_path}")
    gdb.execute('quit', to_string=True)
