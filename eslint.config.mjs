import js from '@eslint/js';
import globals from 'globals';
import lwc from '@lwc/eslint-plugin-lwc';

export default [
    {
        files: ['**/*.js'],
        languageOptions: {
            parser: require('@babel/eslint-parser'),
            parserOptions: {
                ecmaVersion: 2020,
                requireConfigFile: false,
                babelOptions: {
                    plugins: ['@babel/plugin-proposal-class-properties', '@babel/plugin-proposal-decorators'],
                },
            },
            globals: {
                ...globals.browser,
            },
        },
        plugins: {
            '@lwc/lwc': lwc,
        },
        extends: ["@salesforce/eslint-config-lwc/recommended"],
        rules: {
            ...js.configs.recommended.rules,
            '@lwc/lwc/no-deprecated': 'error',
            '@lwc/lwc/valid-api': 'error',
            '@lwc/lwc/no-document-query': 'error',
            '@lwc/lwc/ssr-no-unsupported-property': 'error',
        },
    },
];