/**
 * UI utilities - colors, icons, formatting
 */

import chalk from 'chalk';

// Icons
export const icons = {
  ok: chalk.green('✓'),
  missing: chalk.red('✗'),
  update: chalk.yellow('↑'),
  arrow: chalk.dim('→'),
  bullet: chalk.dim('•'),
  star: '🎨',
  package: '📦',
  rocket: '🚀',
  check: '✅',
  warn: '⚠️',
  info: 'ℹ️',
};

// Styled text
export const ui = {
  // Headers
  header: (text) => chalk.bold(text),
  title: (text) => chalk.bold.cyan(text),
  subtitle: (text) => chalk.dim(text),
  
  // Status
  success: (text) => chalk.green(text),
  error: (text) => chalk.red(text),
  warning: (text) => chalk.yellow(text),
  info: (text) => chalk.blue(text),
  
  // Content
  highlight: (text) => chalk.cyan(text),
  dim: (text) => chalk.dim(text),
  bold: (text) => chalk.bold(text),
  
  // Module names
  module: (text) => chalk.cyan(text),
  
  // File paths
  path: (text) => chalk.dim(text),
};

// Print functions
export function printHeader() {
  console.log();
  console.log(chalk.bold('══════════════════════════════════════════'));
  console.log(chalk.bold(`  ${icons.star} Primer - Project Bootstrapper`));
  console.log(chalk.bold('══════════════════════════════════════════'));
  console.log();
}

export function printSection(title) {
  console.log();
  console.log(ui.title(title));
  console.log(chalk.dim('─────────────────────────────────────────'));
}

export function printSuccess(message) {
  console.log(`  ${icons.ok} ${message}`);
}

export function printError(message) {
  console.log(`  ${icons.missing} ${ui.error(message)}`);
}

export function printWarning(message) {
  console.log(`  ${icons.update} ${ui.warning(message)}`);
}

export function printInfo(message) {
  console.log(`  ${icons.bullet} ${message}`);
}

export function printStep(message) {
  console.log(`  ${icons.arrow} ${message}`);
}

// Box drawing
export function printBox(lines, { padding = 1, borderColor = 'dim' } = {}) {
  const colorFn = chalk[borderColor] || chalk.dim;
  const maxLen = Math.max(...lines.map(l => l.length));
  const width = maxLen + (padding * 2);
  
  console.log(colorFn('┌' + '─'.repeat(width) + '┐'));
  for (const line of lines) {
    const padded = ' '.repeat(padding) + line + ' '.repeat(width - line.length - padding);
    console.log(colorFn('│') + padded + colorFn('│'));
  }
  console.log(colorFn('└' + '─'.repeat(width) + '┘'));
}

// Table printing
export function printTable(rows, { indent = 2, gap = 2 } = {}) {
  const col1Width = Math.max(...rows.map(r => r[0].length));
  const prefix = ' '.repeat(indent);
  
  for (const [col1, col2] of rows) {
    const padded = col1.padEnd(col1Width + gap);
    console.log(`${prefix}${ui.highlight(padded)}${col2}`);
  }
}
