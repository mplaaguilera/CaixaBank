import { defineConfig } from 'eslint/config';
import eslintJs from '@eslint/js';
import jestPlugin from 'eslint-plugin-jest';
import auraConfig from '@salesforce/eslint-plugin-aura';
import lwcConfig from '@salesforce/eslint-config-lwc/recommended.js';
import globals from 'globals';

export default defineConfig([
    // Aura JavaScript configuration
    {
        files: ['**/aura/**/*.js'],
        extends: [
            ...auraConfig.configs.recommended,
            ...auraConfig.configs.locker
        ],
        languageOptions: {
            globals: {
                ...globals.browser,
                // Aura framework globals
                $A: 'readonly',
                Component: 'readonly',
                Event: 'readonly',
                Helper: 'readonly'
            }
        }
    },

    // Aura markup configuration (.cmp, .app files)
    {
        files: ['**/aura/**/*.cmp', '**/aura/**/*.app'],
        plugins: {
            '@salesforce/aura': auraConfig
        },
        languageOptions: {
            parser: '@salesforce/eslint-plugin-aura/lib/parsers/html-parser'
        },
        rules: {
            '@salesforce/aura/aura-api': 'error',
            '@salesforce/aura/secure-document': 'error'
        }
    },

    // LWC configuration
    {
        files: ['**/lwc/**/*.js'],
        extends: [lwcConfig]
    },

    // LWC configuration with override for LWC test files
    {
        files: ['**/lwc/**/*.test.js'],
        extends: [lwcConfig],
        rules: {
            '@lwc/lwc/no-unexpected-wire-adapter-usages': 'off'
        },
        languageOptions: {
            globals: {
                ...globals.node
            }
        }
    },

    // Jest mocks configuration
    {
        files: ['**/jest-mocks/**/*.js'],
        languageOptions: {
            sourceType: 'module',
            ecmaVersion: 'latest',
            globals: {
                ...globals.node,
                ...globals.es2021,
                ...jestPlugin.environments.globals.globals
            }
        },
        plugins: {
            eslintJs
        },
        extends: ['eslintJs/recommended']
    }
]);