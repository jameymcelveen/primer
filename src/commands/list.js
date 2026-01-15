/**
 * primer list - List available modules
 */

import { ModuleRunner } from '../core/module-runner.js';
import { Config } from '../core/config.js';
import {
  ui,
  icons,
  printHeader,
  printSection,
  printTable,
} from '../utils/ui.js';

/**
 * List command handler
 */
export async function listCommand(options) {
  printHeader();

  const runner = new ModuleRunner();
  const modules = runner.getAvailableModules();

  if (modules.length === 0) {
    console.log(`  ${ui.warning('No modules found.')}`);
    console.log();
    return;
  }

  // Check if config exists to show which modules are active
  const { config } = Config.find(process.cwd());
  const activeModules = config?.modules || [];

  printSection('Available Modules');
  console.log();

  if (options.all) {
    // Detailed view
    for (const mod of modules) {
      const isActive = activeModules.includes(mod.name);
      const status = isActive ? icons.ok : icons.bullet;
      const statusText = isActive ? ui.success('(active)') : '';

      console.log(`  ${status} ${ui.module(mod.name)} ${statusText}`);
      if (mod.description) {
        console.log(`      ${ui.dim(mod.description)}`);
      }
      console.log(`      ${ui.dim('Path:')} ${ui.path(mod.path)}`);
      console.log();
    }
  } else {
    // Simple table view
    const rows = modules.map((mod) => {
      const isActive = activeModules.includes(mod.name);
      const prefix = isActive ? `${icons.ok} ` : '  ';
      return [prefix + mod.name, mod.description];
    });

    printTable(rows);
    console.log();

    if (activeModules.length > 0) {
      console.log(`  ${ui.dim(`${icons.ok} = active in current project`)}`);
      console.log();
    }
  }

  // Summary
  console.log(`  ${ui.dim(`${modules.length} modules available`)}`);
  if (config) {
    console.log(`  ${ui.dim(`${activeModules.length} active in primer.yaml`)}`);
  }
  console.log();
}
