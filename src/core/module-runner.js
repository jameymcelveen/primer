/**
 * Module runner - executes module install scripts
 */

import { spawn } from 'child_process';
import { existsSync, readdirSync, readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import ora from 'ora';
import { ui, icons, printSuccess, printError, printStep } from '../utils/ui.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Modules directory (relative to package root)
const MODULES_DIR = join(__dirname, '..', '..', 'modules');

/**
 * Module runner class
 */
export class ModuleRunner {
  constructor(options = {}) {
    this.modulesDir = options.modulesDir || MODULES_DIR;
    this.cwd = options.cwd || process.cwd();
    this.verbose = options.verbose || false;
  }

  /**
   * Get list of available modules
   */
  getAvailableModules() {
    if (!existsSync(this.modulesDir)) {
      return [];
    }

    const entries = readdirSync(this.modulesDir, { withFileTypes: true });
    const modules = [];

    for (const entry of entries) {
      if (entry.isDirectory()) {
        const modulePath = join(this.modulesDir, entry.name);
        const installScript = join(modulePath, 'install.sh');
        const descriptionFile = join(modulePath, 'description.txt');

        if (existsSync(installScript)) {
          let description = '';
          if (existsSync(descriptionFile)) {
            description = readFileSync(descriptionFile, 'utf8').trim();
          }

          modules.push({
            name: entry.name,
            description,
            path: modulePath,
            installScript,
          });
        }
      }
    }

    return modules.sort((a, b) => a.name.localeCompare(b.name));
  }

  /**
   * Check if a module exists
   */
  moduleExists(moduleName) {
    const modulePath = join(this.modulesDir, moduleName, 'install.sh');
    return existsSync(modulePath);
  }

  /**
   * Run a single module
   */
  async runModule(moduleName, options = {}) {
    const installScript = join(this.modulesDir, moduleName, 'install.sh');

    if (!existsSync(installScript)) {
      throw new Error(`Module not found: ${moduleName}`);
    }

    const spinner = ora({
      text: `Running ${ui.module(moduleName)}...`,
      prefixText: '  ',
    }).start();

    try {
      await this.executeScript(installScript, options);
      spinner.succeed(`${ui.module(moduleName)} completed`);
      return { success: true, module: moduleName };
    } catch (error) {
      spinner.fail(`${ui.module(moduleName)} failed`);
      if (this.verbose) {
        console.error(`    ${ui.error(error.message)}`);
      }
      return { success: false, module: moduleName, error };
    }
  }

  /**
   * Run multiple modules
   */
  async runModules(moduleNames, options = {}) {
    const results = [];

    for (const moduleName of moduleNames) {
      const result = await this.runModule(moduleName, options);
      results.push(result);

      // Stop on failure unless continueOnError is set
      if (!result.success && !options.continueOnError) {
        break;
      }
    }

    return results;
  }

  /**
   * Execute a shell script
   */
  executeScript(scriptPath, options = {}) {
    return new Promise((resolve, reject) => {
      // Detect shell based on platform
      const isWindows = process.platform === 'win32';
      const shell = isWindows ? 'powershell.exe' : '/bin/zsh';
      const shellArgs = isWindows ? ['-File', scriptPath] : [scriptPath];

      // For now, only support Unix shells
      if (isWindows) {
        // TODO: Implement Windows PowerShell support
        reject(new Error('Windows support coming soon. Use WSL for now.'));
        return;
      }

      const child = spawn(shell, shellArgs, {
        cwd: this.cwd,
        stdio: this.verbose ? 'inherit' : 'pipe',
        env: {
          ...process.env,
          PRIMER_PROJECT_DIR: this.cwd,
          PRIMER_MODULE_OPTIONS: JSON.stringify(options),
        },
      });

      let stdout = '';
      let stderr = '';

      if (!this.verbose) {
        child.stdout?.on('data', (data) => {
          stdout += data.toString();
        });
        child.stderr?.on('data', (data) => {
          stderr += data.toString();
        });
      }

      child.on('close', (code) => {
        if (code === 0) {
          resolve({ stdout, stderr });
        } else {
          reject(new Error(`Script exited with code ${code}\n${stderr}`));
        }
      });

      child.on('error', (error) => {
        reject(error);
      });
    });
  }
}

/**
 * Create a default module runner
 */
export function createModuleRunner(options = {}) {
  return new ModuleRunner(options);
}
