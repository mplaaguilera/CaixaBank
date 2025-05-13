import {defineConfig} from 'eslint/config';
import salesforceEslintPluginAura from '@salesforce/eslint-plugin-aura';
import lwcEslintPluginLwc from '@lwc/eslint-plugin-lwc';
import marc from 'eslint-plugin-marc';
import globals from 'globals';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import js from '@eslint/js';
import {FlatCompat} from '@eslint/eslintrc';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
	baseDirectory: __dirname,
	recommendedConfig: js.configs.recommended,
	allConfig: js.configs.all
});

export default defineConfig([{
	extends: compat.extends(
		'eslint:recommended',
		'plugin:@salesforce/eslint-plugin-aura/recommended',
		'plugin:@salesforce/eslint-plugin-aura/locker',
		'@salesforce/eslint-config-lwc/extended',
		'@locker/eslint-config-locker/recommended',
	),

	plugins: {
		'@salesforce/aura': salesforceEslintPluginAura,
		'@lwc/lwc': lwcEslintPluginLwc,
		marc,
	},

	languageOptions: {
		globals: {
			...globals.browser,
		},

		ecmaVersion: 2018,
		sourceType: 'module',
	},

	rules: {
		'marc/strict-eqeqeq': 'error',
		'@lwc/lwc/no-unexpected-wire-adapter-usages': 'off',
		'@lwc/lwc/no-async-operation': 'off',
		'@locker/locker/distorted-window-set-timeout': 'off',

		'indent': ['warn', 'tab', {
			SwitchCase: 1,
			MemberExpression: 'off',
		}],

		'linebreak-style': ['error', 'unix'],
		'quotes': ['error', 'single'],

		'semi': ['error', 'always', {
			omitLastInOneLineBlock: true,
		}],

		'keyword-spacing': ['error', {
			before: true,
			after: true,
		}],

		'space-before-blocks': ['warn', 'always'],
		'no-trailing-spaces': ['warn'],
		'no-confusing-arrow': ['off'],
		'comma-dangle': ['error', 'only-multiline'],
		'dot-notation': ['off'],
		'camelcase': ['error'],
		'no-useless-catch': ['error'],
		'eqeqeq': ['error', 'smart'],
		'no-empty': ['error'],
		'no-dupe-keys': ['error'],
		'no-dupe-args': ['error'],
		'no-cond-assign': ['error'],
		'quote-props': ['error', 'consistent'],
		'semi-style': ['error', 'last'],
		'no-var': ['error'],

		'key-spacing': ['warn', {
			beforeColon: false,
		}],

		'arrow-parens': ['warn', 'as-needed'],
		'no-redeclare': ['error'],
		'no-shadow': ['error'],

		'no-console': ['error', {
			allow: ['error'],
		}],

		'no-duplicate-case': ['error'],
		'no-extra-boolean-cast': ['error'],
		'no-extra-parens': ['error'],
		'no-extra-semi': ['error'],

		'no-irregular-whitespace': ['error', {
			skipStrings: true,
			skipComments: true,
		}],

		'no-unexpected-multiline': ['error'],
		'no-unreachable': ['error'],
		'no-unsafe-finally': ['error'],
		'block-scoped-var': ['error'],
		'complexity': ['error', 35],
		'curly': ['error'],
		'no-empty-function': ['error'],
		'no-self-assign': ['error'],
		'no-self-compare': ['error'],
		'no-unused-labels': ['error'],
		'no-useless-concat': ['error'],
		'no-useless-escape': ['error'],
		'no-label-var': ['error'],
		'no-undef-init': ['error'],
		'no-undefined': ['error'],
		'no-unused-vars': ['warn'],
		'vars-on-top': ['off'],
		'no-use-before-define': ['error'],
		'array-bracket-spacing': ['error'],
		'block-spacing': ['error', 'never'],

		'space-before-function-paren': ['error', {
			anonymous: 'never',
			named: 'never',
			asyncArrow: 'always',
		}],

		'space-in-parens': ['error', 'never'],
		'space-unary-ops': ['error'],
		'spaced-comment': ['warn', 'never'],
		'arrow-body-style': ['error', 'as-needed'],
		'no-dupe-class-members': ['error'],
		'no-useless-constructor': ['error'],
		'no-useless-computed-key': ['error'],
		'no-useless-rename': ['error'],
		'prefer-arrow-callback': ['error'],
		'no-whitespace-before-property': ['error'],
		'no-mixed-spaces-and-tabs': ['error'],
		'new-cap': ['error'],
		'lines-between-class-members': ['warn', 'always'],
		'function-paren-newline': ['warn', 'consistent'],
		'eol-last': ['error', 'never'],
		'computed-property-spacing': ['error', 'never'],

		'brace-style': ['error', '1tbs', {
			allowSingleLine: true,
		}],

		'no-alert': ['warn'],
		'space-infix-ops': ['error'],
		'object-curly-spacing': ['warn', 'never'],

		'comma-spacing': ['error', {
			before: false,
			after: true,
		}],

		'default-case': 'warn',
		'no-return-assign': 'off',
		'no-else-return': 'off',
		'no-return-await': 'off',
		'no-unused-expressions': 'off',
		'compat/compat': 'off',
		'@lwc/lwc/no-async-await': 'off',
		'@lwc/lwc/no-for-of': 'off',
		'@salesforce/aura/ecma-intrinsics': 'off',
	},
}]);