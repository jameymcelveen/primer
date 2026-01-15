#!/usr/bin/env node

/**
 * Primer CLI
 * A composable, idempotent project bootstrapping system
 */

import { program } from 'commander';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { readFileSync } from 'fs';

// Import commands
import { initCommand } from '../src/commands/init.js';
import { addCommand } from '../src/commands/add.js';
import { listCommand } from '../src/commands/list.js';
import { runCommand } from '../src/commands/run.js';

// Get package version
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const pkg = JSON.parse(readFileSync(join(__dirname, '..', 'package.json'), 'utf8'));

program
  .name('primer')
  .description('🎨 Primer - A composable, idempotent project bootstrapping system')
  .version(pkg.version, '-v, --version');

// primer init
program
  .command('init')
  .description('Initialize a new project (interactive wizard)')
  .option('-y, --yes', 'Skip prompts and use defaults')
  .option('-t, --template <name>', 'Use a predefined template')
  .action(initCommand);

// primer add <module>
program
  .command('add [modules...]')
  .description('Add modules to an existing project')
  .option('-s, --save', 'Save to primer.yaml', true)
  .action(addCommand);

// primer list
program
  .command('list')
  .alias('ls')
  .description('List available modules')
  .option('-a, --all', 'Show detailed information')
  .action(listCommand);

// primer run
program
  .command('run')
  .description('Run modules from primer.yaml')
  .option('-m, --modules <modules...>', 'Run specific modules only')
  .option('-c, --config <file>', 'Use a specific config file', 'primer.yaml')
  .action(runCommand);

// Handle no command
program.action(() => {
  program.help();
});

program.parse();
