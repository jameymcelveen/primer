/**
 * Interactive prompts for Primer CLI
 */

import inquirer from 'inquirer';
import { ui, icons } from './ui.js';

/**
 * Prompt for project details during init
 */
export async function promptProjectDetails(defaults = {}) {
  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'name',
      message: 'Project name:',
      default: defaults.name || 'my-project',
      validate: (input) => {
        if (!input.trim()) return 'Project name is required';
        if (!/^[a-z0-9-_]+$/i.test(input)) {
          return 'Project name can only contain letters, numbers, hyphens, and underscores';
        }
        return true;
      },
    },
    {
      type: 'input',
      name: 'description',
      message: 'Description:',
      default: defaults.description || '',
    },
  ]);

  return answers;
}

/**
 * Prompt for module selection
 */
export async function promptModuleSelection(modules, defaults = []) {
  const choices = modules.map((mod) => ({
    name: `${ui.module(mod.name.padEnd(15))} ${ui.dim(mod.description)}`,
    value: mod.name,
    checked: defaults.includes(mod.name),
  }));

  const { selectedModules } = await inquirer.prompt([
    {
      type: 'checkbox',
      name: 'selectedModules',
      message: 'Select modules to include:',
      choices,
      pageSize: 15,
    },
  ]);

  return selectedModules;
}

/**
 * Prompt for module options
 */
export async function promptModuleOptions(moduleName, optionSchema) {
  // For now, return empty - we'll implement per-module options later
  return {};
}

/**
 * Confirm action
 */
export async function confirm(message, defaultValue = true) {
  const { confirmed } = await inquirer.prompt([
    {
      type: 'confirm',
      name: 'confirmed',
      message,
      default: defaultValue,
    },
  ]);

  return confirmed;
}

/**
 * Select from list
 */
export async function select(message, choices, defaultValue) {
  const { selected } = await inquirer.prompt([
    {
      type: 'list',
      name: 'selected',
      message,
      choices,
      default: defaultValue,
    },
  ]);

  return selected;
}

/**
 * Multi-select from list
 */
export async function multiSelect(message, choices, defaults = []) {
  const { selected } = await inquirer.prompt([
    {
      type: 'checkbox',
      name: 'selected',
      message,
      choices: choices.map((c) => ({
        name: typeof c === 'string' ? c : c.name,
        value: typeof c === 'string' ? c : c.value,
        checked: defaults.includes(typeof c === 'string' ? c : c.value),
      })),
    },
  ]);

  return selected;
}

/**
 * Text input
 */
export async function input(message, defaultValue = '') {
  const { value } = await inquirer.prompt([
    {
      type: 'input',
      name: 'value',
      message,
      default: defaultValue,
    },
  ]);

  return value;
}
