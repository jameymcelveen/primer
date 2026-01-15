/**
 * primer run - Run modules from primer.yaml
 */

import { join } from 'path';
import { Config } from '../core/config.js';
import { ModuleRunner } from '../core/module-runner.js';
import {
  ui,
  icons,
  printHeader,
  printSection,
  printSuccess,
  printError,
  printWarning,
  printInfo,
} from '../utils/ui.js';

/**
 * Run command handler
 */
export async function runCommand(options) {
  printHeader();

  const cwd = process.cwd();

  // Load config
  let config;
  let configPath;

  if (options.config) {
    configPath = options.config.startsWith('/')
      ? options.config
      : join(cwd, options.config);

    try {
      config = Config.load(configPath);
    } catch (error) {
      printError(`Could not load config: ${error.message}`);
      process.exit(1);
    }
  } else {
    const result = Config.find(cwd);
    if (!result.config) {
      printError('No primer.yaml found in current directory');
      console.log();
      console.log(`  ${ui.dim('Run')} ${ui.highlight('primer init')} ${ui.dim('to create one.')}`);
      console.log();
      process.exit(1);
    }
    config = result.config;
    configPath = result.filePath;
  }

  // Determine which modules to run
  let modulesToRun = config.modules;

  if (options.modules && options.modules.length > 0) {
    // Filter to only specified modules
    modulesToRun = options.modules.filter((m) => config.modules.includes(m));

    const notInConfig = options.modules.filter((m) => !config.modules.includes(m));
    if (notInConfig.length > 0) {
      for (const mod of notInConfig) {
        printWarning(`Module ${ui.module(mod)} is not in config, skipping`);
      }
    }
  }

  if (modulesToRun.length === 0) {
    printWarning('No modules to run');
    console.log();
    return;
  }

  // Show what we're running
  console.log(`  ${ui.dim('Project:')} ${ui.highlight(config.name)}`);
  console.log(`  ${ui.dim('Config:')}  ${ui.path(configPath)}`);
  console.log(`  ${ui.dim('Modules:')} ${modulesToRun.map(m => ui.module(m)).join(', ')}`);

  // Run modules
  console.log();
  printSection('Running Modules');
  console.log();

  const runner = new ModuleRunner({ cwd, verbose: options.verbose });

  // Pass module-specific options
  const results = [];
  for (const moduleName of modulesToRun) {
    const moduleOptions = config.getModuleOptions(moduleName);
    const result = await runner.runModule(moduleName, moduleOptions);
    results.push(result);

    if (!result.success && !options.force) {
      break;
    }
  }

  // Summary
  const succeeded = results.filter((r) => r.success);
  const failed = results.filter((r) => !r.success);

  console.log();
  printSection('Summary');
  console.log();

  if (failed.length > 0) {
    console.log(`  ${icons.ok} ${succeeded.length} modules completed`);
    console.log(`  ${icons.missing} ${failed.length} modules failed`);

    for (const f of failed) {
      console.log(`      ${ui.dim('•')} ${ui.error(f.module)}: ${f.error?.message || 'Unknown error'}`);
    }

    console.log();
    process.exit(1);
  } else {
    printSuccess(`All ${succeeded.length} modules completed successfully!`);
    console.log();
  }
}
