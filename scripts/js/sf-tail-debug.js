#!/usr/bin/env node

const { spawn } = require('child_process');
const readline = require('readline');

const sf = spawn('sf', [
	'apex',
	'tail',
	'log',
	'--debug-level',
	'ApexUserDebug'
]);

const methodStack = [];
let rootMethod = null;
let lastStatementLine = '?';
let lastErrorLine = null;
let isFirstFile = true;
let currentRootMethod = null;
let waitingForThirdLine = false;
let lineCount = 0;
let lastTimestamp = null;

const ANSI_REGEX = /\x1B\[[0-?]*[ -/]*[@-~]/g;

function isConstructor(className, methodName) {
	const simpleClassName = className.split('.').pop();
	const cleanMethodName = methodName.replace(/\(\*?\)/, '').replace(/\(\)/, '');
	return simpleClassName === cleanMethodName;
}

const rl = readline.createInterface({ input: sf.stdout, terminal: false });

rl.on('line', (line) => {
	// Capturar la tercera línia després del separador si estem esperant-la
	if (waitingForThirdLine && !line.includes('<unknown>') && !/^\d+\.\d+ (APEX_CODE|SYSTEM|DB|VISUALFORCE|.*);/.test(line)) {
		lineCount++;
		if (lineCount === 3) {
			// Extraure el contingut de la línia (sense timestamp)
			const timestamp = line.trim().split(' ')[0];
			const content = line.trim().slice(timestamp.length).trim();
			if (content) {
				currentRootMethod = content;
			}
		}
	}

	// Guardar el timestamp de les línies útils
	if (!line.includes('<unknown>') && !/^\d+\.\d+ (APEX_CODE|SYSTEM|DB|VISUALFORCE|.*);/.test(line)) {
		const timestamp = line.trim().split(' ')[0];
		if (timestamp && /^\d{2}:\d{2}:\d{2}$/.test(timestamp)) {
			lastTimestamp = timestamp;
		}
	}

	// També guardar timestamp de les línies d'error i debug
	if (line.includes('|USER_DEBUG|') || line.includes('|FATAL_ERROR|')) {
		const parts = line.split('|');
		const timestamp = parts[0].trim().split(' ')[0].split('.')[0];
		if (timestamp && /^\d{2}:\d{2}:\d{2}$/.test(timestamp)) {
			lastTimestamp = timestamp;
		}
	}

	// Pintar en rosa línies amb context desconegut
	if (line.includes('<unknown>')) {
		const timestamp = line.trim().split(' ')[0];
		const rest = line.trim().slice(timestamp.length).trim();
		// Rosa: RGB(255,105,180)
		console.log(`\x1b[38;2;255;105;180m${timestamp}  ${rest}\x1b[0m`);
		console.log();
		return;
	}
			// Separador per nous fils
	if (/^\d+\.\d+ (APEX_CODE|SYSTEM|DB|VISUALFORCE|.*);/.test(line)) {
		methodStack.length = 0;
		rootMethod = null;
		lastStatementLine = '?';
		lastErrorLine = null;

		// Només mostrar fi de fil si hi ha hagut contingut útil
		if (!isFirstFile && currentRootMethod) {
			// console.log(`\x1b[90m${lastTimestamp || '??:??:??'}  -- FI de ${currentRootMethod} --\x1b[0m`);
			console.log();
			console.log();
		}

		// No mostrar inici de fil immediatament, esperar a la tercera línia
		isFirstFile = false;
		currentRootMethod = null;
		waitingForThirdLine = true;
		lineCount = 0;
		return;
	}

	if (line.includes('|EXECUTION_STARTED')) {
		methodStack.length = 0;
		rootMethod = null;
		lastStatementLine = '?';
		lastErrorLine = null;
		return;
	}

	if (line.includes('|CODE_UNIT_FINISHED|')) {
		methodStack.pop();
		return;
	}

	if (line.includes('|STATEMENT_EXECUTE|')) {
		const parts = line.split('|');
		const lineNumMatch = parts[2]?.match(/\[(\d+)\]/);
		if (lineNumMatch) lastStatementLine = lineNumMatch[1];
		return;
	}

	if (line.includes('|CODE_UNIT_STARTED|') && !line.includes('apex://')) {
		const parts = line.split('|');
		rootMethod = parts[parts.length - 1] || '<unknown>';
		currentRootMethod = rootMethod;
		methodStack.length = 0;
		const timestamp = parts[0].trim().split(' ')[0].split('.')[0];
		const [className, methodName] = splitClassAndMethod(rootMethod);
		if (className === '<unknown>') {
			console.log(`\x1b[90m${timestamp}  -- \x1b[38;2;255;105;180mInici de\x1b[0m \x1b[38;2;70;130;200m${rootMethod}\x1b[0m --\x1b[0m`);
			console.log();
			methodStack.push(rootMethod);
			return;
		}
		// Usar un blau més fort que el de les classes
		const coloredTimestamp = `\x1b[90m${timestamp}\x1b[0m`;
		const coloredPrefix = `\x1b[38;2;255;105;180mInici de\x1b[0m`;
		const coloredMethod = `\x1b[38;2;70;130;200m${className}.${methodName}\x1b[0m`;
		console.log(`${coloredTimestamp}  -- ${coloredPrefix} ${coloredMethod} --`);
		console.log(`               |`);
		methodStack.push(rootMethod);
		return;
	}

	if (line.includes('|METHOD_ENTRY|')) {
		const parts = line.split('|');
		const method = parts[parts.length - 1] || '<unknown>';
		const lineNumMatch = (parts[2] || '').match(/\[(\d+)\]/);
		const lineNum = lineNumMatch ? `${lineNumMatch[1]}: ` : '';

		const timestamp = parts[0].trim().split(' ')[0].split('.')[0];
		lastTimestamp = timestamp; // Guardar el timestamp
		const [className, methodName] = splitClassAndMethod(method);

		// Excloure constructors (mètode == classe)
		if (isConstructor(className, methodName)) {
			// No mostrar ni comptar
			return;
		}

		// Comprovar si és un mètode amb namespace (exactament dos punts en el nom sense paràmetres)
		const methodNameWithoutParams = method.substring(0, method.indexOf('(') !== -1 ? method.indexOf('(') : method.length);
		const dotCount = (methodNameWithoutParams.match(/\./g) || []).length;

		if (dotCount === 2) {
			// Namespace method: do NOT push to stack, print with flat arrow →
			const indent = ' '.repeat(methodStack.length * 5);
			const coloredTimestamp = `\x1b[90m${timestamp}\x1b[0m`;
			const coloredArrow = '\x1b[38;2;200;200;200m→\x1b[0m';
			const coloredClass = `\x1b[38;2;113;170;231m${className}\x1b[0m`;
			const coloredMethod = `\x1b[38;2;173;216;230m${methodName}\x1b[0m`;
			console.log(`${coloredTimestamp}  ${indent}|${coloredArrow}  ${coloredClass}.${coloredMethod}`);
			console.log(`          ${indent}|`);
			return;
		}
		if (className === '<unknown>') {
			console.log(`\x1b[38;2;70;130;200m${timestamp}  ${method}${lineNum}\x1b[0m`);
			console.log();
			return;
		}

		methodStack.push(`${method}${lineNum}`);
		const indent = ' '.repeat((methodStack.length - 1) * 5);
		const coloredTimestamp = `\x1b[90m${timestamp}\x1b[0m`;
		const coloredArrow = '\x1b[38;2;200;200;200m⤷\x1b[0m';
		const coloredClass = `\x1b[38;2;113;170;231m${className}\x1b[0m`;
		const coloredMethod = `\x1b[38;2;173;216;230m${methodName}\x1b[0m`;
		console.log(`${coloredTimestamp}  ${indent}${coloredArrow}  ${coloredClass}.${coloredMethod}`);
		console.log();
		return;
	}

	if (line.includes('|METHOD_EXIT|')) {
		const parts = line.split('|');
		const exitRaw = (parts[parts.length - 1] || '');
		const cleanMethod = exitRaw.replace(/\[\d+\]$/, '');
		const [className, methodName] = splitClassAndMethod(cleanMethod);

		// If exitRaw has no dots, it's a constructor exit, ignore it
		if (!exitRaw.includes('.')) {
			return;
		}

		// Comprovar si és un mètode amb namespace (exactament dos punts en el nom sense paràmetres)
		const methodNameWithoutParams = cleanMethod.substring(0, cleanMethod.indexOf('(') !== -1 ? cleanMethod.indexOf('(') : cleanMethod.length);
		const dotCount = (methodNameWithoutParams.match(/\./g) || []).length;

		if (dotCount === 2) {
			// Namespace method: do NOT pop from stack, do NOT print anything
			return;
		}
		const popped = methodStack.pop();
		const timestamp = parts[0].trim().split(' ')[0].split('.')[0];
		lastTimestamp = timestamp; // Guardar el timestamp
		const coloredTimestamp = `\x1b[90m${timestamp}\x1b[0m`;
		const indent = ' '.repeat(methodStack.length * 5);
		const coloredClass = `\x1b[38;2;113;170;231m${className}\x1b[0m`;
		const coloredMethod = `\x1b[38;2;173;216;230m${methodName}\x1b[0m`;
		const coloredExitArrow = '\x1b[38;2;200;200;200m⤹\x1b[0m';
		console.log(`${coloredTimestamp}  ${indent}${coloredExitArrow}  ${coloredClass}.${methodName}`);
		console.log();
		return;
	}

	if (line.includes('|USER_DEBUG|')) {
		const parts = line.split('|');
		const timestamp = parts[0].trim().split(' ')[0].split('.')[0];
		lastTimestamp = timestamp; // Guardar el timestamp
		const lineNumMatch = (parts[2] || '').match(/\d+/);
		const lineNum = lineNumMatch ? lineNumMatch[0] : '?';
		let message = parts.slice(4).join('|').replace(/^DEBUG\|/, '').trim();
		message = message.replace(ANSI_REGEX, '');
		if (!message) message = '<sense missatge>';
		const indent = ' '.repeat(methodStack.length * 5);
		const coloredTimestamp = `\x1b[90m${timestamp}\x1b[0m`;
		const coloredLineNum = `\x1b[38;2;113;170;231m${lineNum}:\x1b[0m`;
		const coloredPrefix = `\x1b[37mDEBUG: \x1b[0m`;
		const coloredMessage = `\x1b[38;2;255;220;0m${message}\x1b[0m`;
		console.log(`${coloredTimestamp}  ${indent}|${coloredLineNum} ${coloredPrefix}${coloredMessage}`);
		console.log(`          ${indent}|`);
		return;
	}

	if (line.includes('|FATAL_ERROR|')) {
		const parts = line.split('|');
		const timestamp = parts[0].trim().split(' ')[0].split('.')[0];
		lastTimestamp = timestamp; // Guardar el timestamp
		const indent = ' '.repeat(methodStack.length > 0 ? (methodStack.length) * 5 : 5);
		const message = parts.slice(2).join('|').replace(/^System\./, '').trim();

		// Si l'últim error ja era per aquesta línia, el saltem
		if (lastErrorLine === lastStatementLine) {
			return;
		}
		lastErrorLine = lastStatementLine;

		const coloredTimestamp = `\x1b[90m${timestamp}\x1b[0m`;
		const coloredLineNum = `\x1b[38;2;113;170;231m${lastStatementLine}:\x1b[0m`;
		const coloredPrefix = `\x1b[37mERROR: \x1b[0m`;
		const coloredMessage = `\x1b[38;2;255;0;0m${message}\x1b[0m`;
		console.log(`${coloredTimestamp}  ${indent}|${coloredLineNum} ${coloredPrefix}${coloredMessage}`);
		console.log(`          ${indent}|`);
		return;
	}
});

sf.stderr.on('data', (data) => {
	console.error(`❌ Error sf cli: ${data}`);
});

sf.on('close', (code) => {
	if (code !== 0) console.error(`sf apex tail exited with code ${code}`);
});

function splitClassAndMethod(fullMethod) {
	// Trobar el primer parèntesi obert per identificar on comencen els paràmetres
	const firstParenIndex = fullMethod.indexOf('(');

	// Si no hi ha parèntesis, usar la lògica original
	if (firstParenIndex === -1) {
		const parts = fullMethod.split('.');
		if (parts.length >= 2) {
			const methodName = parts.pop();
			const className = parts.join('.');
			return [className, methodName];
		}
		return ['<unknown>', fullMethod];
	}

	// Separar el nom del mètode (sense paràmetres) dels paràmetres
	const methodNameWithoutParams = fullMethod.substring(0, firstParenIndex);
	const params = fullMethod.substring(firstParenIndex);

	// Comptar punts només en la part del nom del mètode (sense paràmetres)
	const parts = methodNameWithoutParams.split('.');
	if (parts.length >= 2) {
		const methodName = parts.pop() + params; // Afegir els paràmetres de tornada
		const className = parts.join('.');
		return [className, methodName];
	}
	return ['<unknown>', fullMethod];
}