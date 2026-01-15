/**
 * Configuration file handling
 */

import { readFileSync, writeFileSync, existsSync } from 'fs';
import { join } from 'path';
import YAML from 'yaml';

const CONFIG_FILENAMES = ['primer.yaml', 'primer.yml'];

/**
 * Config class for managing primer.yaml
 */
export class Config {
  constructor(data = {}) {
    this.name = data.name || 'my-project';
    this.description = data.description || '';
    this.modules = data.modules || [];
    this.options = data.options || {};
  }

  /**
   * Load config from file
   */
  static load(filePath) {
    if (!existsSync(filePath)) {
      throw new Error(`Config file not found: ${filePath}`);
    }

    const content = readFileSync(filePath, 'utf8');
    const data = YAML.parse(content);
    return new Config(data);
  }

  /**
   * Find and load config from current directory
   */
  static find(dir = process.cwd()) {
    for (const filename of CONFIG_FILENAMES) {
      const filePath = join(dir, filename);
      if (existsSync(filePath)) {
        return { config: Config.load(filePath), filePath };
      }
    }
    return { config: null, filePath: null };
  }

  /**
   * Check if config exists in directory
   */
  static exists(dir = process.cwd()) {
    return CONFIG_FILENAMES.some((f) => existsSync(join(dir, f)));
  }

  /**
   * Save config to file
   */
  save(filePath) {
    const data = {
      name: this.name,
      description: this.description,
      modules: this.modules,
    };

    // Only include options if there are any
    if (Object.keys(this.options).length > 0) {
      data.options = this.options;
    }

    const yaml = YAML.stringify(data, {
      indent: 2,
      lineWidth: 0,
    });

    writeFileSync(filePath, yaml);
  }

  /**
   * Add a module
   */
  addModule(moduleName, options = {}) {
    if (!this.modules.includes(moduleName)) {
      this.modules.push(moduleName);
    }

    if (Object.keys(options).length > 0) {
      this.options[moduleName] = {
        ...(this.options[moduleName] || {}),
        ...options,
      };
    }
  }

  /**
   * Remove a module
   */
  removeModule(moduleName) {
    this.modules = this.modules.filter((m) => m !== moduleName);
    delete this.options[moduleName];
  }

  /**
   * Check if module is included
   */
  hasModule(moduleName) {
    return this.modules.includes(moduleName);
  }

  /**
   * Get options for a module
   */
  getModuleOptions(moduleName) {
    return this.options[moduleName] || {};
  }

  /**
   * Convert to plain object
   */
  toObject() {
    return {
      name: this.name,
      description: this.description,
      modules: this.modules,
      options: this.options,
    };
  }
}

/**
 * Default config template
 */
export function createDefaultConfig(name = 'my-project', description = '') {
  return new Config({
    name,
    description,
    modules: ['base'],
    options: {},
  });
}
