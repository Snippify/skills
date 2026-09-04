#!/usr/bin/env node

const { spawnSync } = require("node:child_process");
const path = require("node:path");

const PACKAGE_ROOT = path.resolve(__dirname, "..");
const DEFAULT_SKILLS = [
  "snippify-base",
  "snippify-private",
  "snippify-public",
  "snippify-team",
];

function printHelp() {
  console.log(`Install Snippify skills into the current Codex environment.

Usage:
  npx snippify-skills [options]

Options:
  --agent <name>        Agent target passed to "skills add" (default: codex)
  --skill <name>        Install one skill. Can be repeated.
  --all                Install all bundled skills (default)
  --list               Print bundled skills and exit
  --dry-run            Print the command that would run
  -h, --help           Show this help

Examples:
  npx snippify-skills
  npx snippify-skills --skill snippify-public
  npx snippify-skills --agent codex --all`);
}

function parseArgs(argv) {
  const options = {
    agent: "codex",
    skills: [],
    list: false,
    dryRun: false,
    help: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];

    if (arg === "--agent") {
      const value = argv[index + 1];
      if (!value || value.startsWith("-")) {
        throw new Error("--agent requires a value");
      }
      options.agent = value;
      index += 1;
    } else if (arg === "--skill") {
      const value = argv[index + 1];
      if (!value || value.startsWith("-")) {
        throw new Error("--skill requires a value");
      }
      options.skills.push(value);
      index += 1;
    } else if (arg === "--all") {
      options.skills = [];
    } else if (arg === "--list") {
      options.list = true;
    } else if (arg === "--dry-run") {
      options.dryRun = true;
    } else if (arg === "-h" || arg === "--help") {
      options.help = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  return options;
}

function commandFor(options) {
  const selectedSkills = options.skills.length > 0 ? options.skills : DEFAULT_SKILLS;
  return [
    "skills",
    "add",
    PACKAGE_ROOT,
    ...selectedSkills.flatMap((skill) => ["--skill", skill]),
    "--agent",
    options.agent,
  ];
}

function shellQuote(value) {
  if (/^[A-Za-z0-9_./:@-]+$/.test(value)) {
    return value;
  }
  return `'${value.replace(/'/g, "'\\''")}'`;
}

function main() {
  let options;

  try {
    options = parseArgs(process.argv.slice(2));
  } catch (error) {
    console.error(error.message);
    console.error("Run with --help for usage.");
    process.exit(2);
  }

  if (options.help) {
    printHelp();
    return;
  }

  if (options.list) {
    console.log(DEFAULT_SKILLS.join("\n"));
    return;
  }

  const command = commandFor(options);

  if (options.dryRun) {
    console.log(["npx", "--yes", ...command].map(shellQuote).join(" "));
    return;
  }

  const npx = process.platform === "win32" ? "npx.cmd" : "npx";
  const result = spawnSync(npx, ["--yes", ...command], {
    stdio: "inherit",
    cwd: process.cwd(),
  });

  if (result.error) {
    console.error(result.error.message);
    process.exit(1);
  }

  process.exit(result.status ?? 1);
}

main();
