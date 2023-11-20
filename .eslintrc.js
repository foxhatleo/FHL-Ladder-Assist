const customRules = {
    "import/extensions": "off",
    "import/prefer-default-export": "off",
    "react/display-name": "off",
    "react/function-component-definition": [
        "error",
        {
            namedComponents: "arrow-function",
            unnamedComponents: "arrow-function",
        },
    ],
    "react/jsx-filename-extension": "off",
    "react/jsx-indent": ["error", 4],
    "react/jsx-indent-props": ["error", 4],
    "react/jsx-props-no-spreading": "off",
    "react/prop-types": "off",
    "react/require-default-props": "off",
    "react/no-array-index-key": "off",
    "react-hooks/exhaustive-deps": "off",
    "class-methods-use-this": "off",
    "indent": ["error", 4],
    "max-len": ["error", { code: 120 }],
    "no-continue": "off",
    "no-shadow": "off",
    "no-unused-vars": "off",
    "no-restricted-syntax": "off",
    "no-underscore-dangle": "off",
    "unused-imports/no-unused-imports": "error",
    "unused-imports/no-unused-vars": [
        "warn",
        {
            vars: "all",
            varsIgnorePattern: "^_",
            args: "after-used",
            argsIgnorePattern: "^_",
        },
    ],
    "quotes": ["error", "double"],
    "quote-props": ["error", "consistent-as-needed"],
    "jsx-quotes": ["error", "prefer-double"],
    "@typescript-eslint/ban-ts-comment": "off",
    "@typescript-eslint/no-explicit-any": "off",
    "@typescript-eslint/no-shadow": "off",
    "@next/next/no-img-element": "off",
};

const tsCustomRules = {
    ...customRules,
    "quotes": "off",
    "indent": "off",
    "@typescript-eslint/naming-convention": "off",
    "@typescript-eslint/quotes": customRules.quotes,
    "@typescript-eslint/indent": customRules.indent,
    "@typescript-eslint/no-unused-vars": "off",
    "@typescript-eslint/member-delimiter-style": ["error", {
        multiline: {
            delimiter: "semi",
            requireLast: true,
        },
        singleline: {
            delimiter: "semi",
            requireLast: false,
        },
        multilineDetection: "brackets",
    }],
};

module.exports = {
    extends: ["airbnb", "eslint:recommended"],
    plugins: ["unused-imports", "import", "react"],
    rules: customRules,
    ignorePatterns: ["android/**"],
    overrides: [
        {
            files: ["**/*.{ts,tsx}"],
            excludedFiles: ["android/**"],
            extends: [
                "airbnb-typescript",
                "plugin:@typescript-eslint/stylistic",
                "plugin:@typescript-eslint/recommended",
                "airbnb",
                "eslint:recommended",
            ],
            parser: "@typescript-eslint/parser",
            parserOptions: {
                project: "./tsconfig.json",
            },
            plugins: ["@typescript-eslint", "unused-imports", "import", "jsx-a11y", "react"],
            rules: tsCustomRules,
        },
    ],
};
