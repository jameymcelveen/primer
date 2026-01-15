/**
 * primer add <module> - Add modules to existing project
 */

import { join } from 'path';
import { Config } from '../core/config.js';
import { ModuleRunner } from '../core/module-runner.js';
import { promptModuleSelection, confirm } from '../utils/prompts.js';
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
 * Add command handler
 */
export async function addCommand(modules, options) {
  printHeader();

  const cwd = process.cwd();
  const configPath = join(cwd, 'primer.yaml');

  // Load or create config
  let config;
  let isNewConfig = false;

  try {
    const result = Config.find(cwd);
    if (result.config) {
      config = result.config;
    } else {
      // No config exists, create a new one
      const dirName = cwd.split('/').pop() || 'my-project';
      config = new Config({ name: dirName, modules: [] });
      isNewConfig = true;
    }
  } catch (error) {
    printError(`Error loading config: ${error.message}`);
    process.exit(1);
  }

  // Get available modules
  const runner = new ModuleRunner();
  const availableModules = runner.getAvailableModules();

  // If no modules specified, show interactive selection
  let modulesToAdd = modules || [];

  if (modulesToAdd.length === 0) {
    printSection('Select Modules to Add');
    console.log();

    // Filter out already installed modules
    const notInstalled = availableModules.filter(
      (m) => !config.hasModule(m.name)
    );

    if (notInstalled.length === 0) {
      printInfo('All available modules are already in your config.');
      console.log();
      return;
    }

    modulesToAdd = await promptModuleSelection(notInstalled, []);

    if (modulesToAdd.length === 0) {
      console.log(`\n  ${ui.dim('No modules selected.')}\n`);
      return;
    }
  }

  // Validate modules
  const validModules = [];
  const invalidModules = [];

  for (const moduleName of modulesToAdd) {
    if (runner.moduleExists(moduleName)) {
      if (config.hasModule(moduleName)) {
        printWarning(`Module ${ui.module(moduleName)} is already in config`);
      } else {
        validModules.push(moduleName);
      }
    } else {
      invalidModules.push(moduleName);
    }
  }

  if (invalidModules.length > 0) {
    console.log();
    for (const mod of invalidModules) {
      printError(`Module not found: ${mod}`);
    }
  }

  if (validModules.length === 0) {
    console.log(`\n  ${ui.dim('No new modules to add.')}\n`);
    return;
  }

  // Add modules to config
  console.log();
  printSection('Adding Modules');
  console.log();

  for (const moduleName of validModules) {
    config.addModule(moduleName);
    printSuccess(`Added ${ui.module(moduleName)} to config`);
  }

  // Save config
  if (options.save !== false) {
    config.save(configPath);
    console.log();
    printSuccess(`Saved ${ui.path('primer.yaml')}`);
  }

  // Ask to run new modules
  console.log();
  const runNow = await confirm('Run new modules now?', true);

  if (runNow) {
    console.log();
    printSection('Running New Modules');
    console.log();

    const results = await runner.runModules(validModules, {
      continueOnError: true,
    });

    const failed = results.filter((r) => !r.success);

    console.log();
    if (failed.length > 0) {
      printWarning(`${failed.length} module(s) had issues`);
    } else {
      printSuccess('All modules completed successfully!');
    }
  }

  console.log();
}
