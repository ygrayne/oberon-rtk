#!/usr/bin/env python3

# Program configuration management
# --
# Copyright (c) 2024 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/

import configparser
from pathlib import Path

class Config():
    _default_cfg = """
    [DEFAULT]
    """
    def __init__(self, cfg_file_name):
        cfg_file_name = cfg_file_name
        self._cfg_file = Path.cwd().joinpath(cfg_file_name)
        self._config = configparser.ConfigParser()
        if self._cfg_file.exists():
            self._config.read(self._cfg_file)
        else:
            self._config.read_string(self._default_cfg)
            self.write_file()

    @property
    def cfg_file(self):
        return self._cfg_file

    def write_file(self):
         with open(self._cfg_file, 'w') as f:
            self._config.write(f)

    def option(self, section, option):
        assert(self._config.has_section(section))
        assert(self._config.has_option(section, option))
        return self._config[section][option]

    def set_option(self, section, option, value):
        assert(self._config.has_section(section))
        assert(self._config.has_option(section, option))
        self._config[section][option] = value
