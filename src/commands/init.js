/**
 * primer init - Initialize a new project
 * 
 * Interactive wizard similar to npm init
 */

import { join } from 'path';
import { existsSync } from 'fs';
import ora from 'ora';
import { Config, createDefaultConfig } from '../core/config.js';
import { ModuleRunner } from '../core/module-runner.js';
import {
  promptProjectDetails,
  promptModuleSelection,
  confirm,
} from '../utils/prompts.js';
import {
  ui,
  icons,
  printHeader,
  printSection,
  printSuccess,
  printError,
  printInfo,
  printStep,
} from '../utils/ui.js';

/**
 * Init command handler
 */
export async function initCommand(options) {
  printHeader();

  const cwd = process.cwd();
  const configPath = join(cwd, 'primer.yaml');

  // Check if config already exists
  if (existsSync(configPath) && !options.yes) {
    console.log(`  ${icons.warn} ${ui.warning('primer.yaml already exists in this directory')}`);
    const overwrite = await confirm('Overwrite existing configuration?', false);
    if (!overwrite) {
      console.log(`\n  ${ui.dim('Cancelled.')}\n`);
      return;
    }
    console.log();
  }

  // Get available modules
  const runner = new ModuleRunner();
  const availableModules = runner.getAvailableModules();

  if (availableModules.length === 0) {
    printError('No modules found. Check your Primer installation.');
    process.exit(1);
  }

  let config;

  if (options.yes) {
    // Quick mode - use defaults
    const dirName = cwd.split('/').pop() || 'my-project';
    config = createDefaultConfig(dirName);
    console.log(`  ${icons.rocket} Quick init with defaults...\n`);
  } else {
    // Interactive mode
    printSection('Project Details');
    console.log();

    // Get project details
    const dirName = cwd.split('/').pop() || 'my-project';
    const projectDetails = await promptProjectDetails({
      name: dirName,
      description: '',
    });

    console.log();
    printSection('Select Modules');
    console.log();

    // Select modules
    const selectedModules = await promptModuleSelection(availableModules, ['base']);

    if (selectedModules.length === 0) {
      console.log(`\n  ${ui.warning('No modules selected. Exiting.')}\n`);
      return;
    }

    // Create config
    config = new Config({
      name: projectDetails.name,
      description: projectDetails.description,
      modules: selectedModules,
      options: {},
    });
  }

  // Save config file
  console.log();
  printSection('Creating Project');
  console.log();

  config.save(configPath);
  printSuccess(`Created ${ui.path('primer.yaml')}`);

  // Ask to run modules now
  console.log();
  const runNow = options.yes || await confirm('Run modules now?', true);

  if (runNow) {
    console.log();
    printSection('Running Modules');
    console.log();

    const results = await runner.runModules(config.modules, {
      continueOnError: false,
    });

    const failed = results.filter((r) => !r.success);
    const succeeded = results.filter((r) => r.success);

    console.log();
    printSection('Complete!');
    console.log();

    if (failed.length > 0) {
      console.log(`  ${icons.ok} ${succeeded.length} modules completed`);
      console.log(`  ${icons.missing} ${failed.length} modules failed`);
      console.log();
      process.exit(1);
    } else {
      printSuccess(`Project ${ui.highlight(config.name)} initialized successfully!`);
      console.log();
      console.log(`  ${ui.dim('Next steps:')}`);
      console.log(`  ${icons.bullet} Edit ${ui.path('primer.yaml')} to customize options`);
      console.log(`  ${icons.bullet} Run ${ui.highlight('primer add <module>')} to add more modules`);
      console.log(`  ${icons.bullet} Run ${ui.highlight('primer run')} to re-run modules`);
      console.log();
    }
  } else {
    console.log();
    printSuccess(`Config saved to ${ui.path('primer.yaml')}`);
    console.log();
    console.log(`  ${ui.dim('Run')} ${ui.highlight('primer run')} ${ui.dim('to install modules.')}`);
    console.log();
  }
}
