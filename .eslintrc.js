module.exports = {
    parser: "@typescript-eslint/parser",
    globals: {
    },
    extends: ["plugin:@typescript-eslint/recommended", "prettier"],
    plugins: ["@typescript-eslint", "prettier"],
    ignorePatterns: [".eslintrc.js"],
    parserOptions: {
        ecmaVersion: 2022,
        tsconfigRootDir: __dirname,
        sourceType: "module",
        project: "./tsconfig.json",
    },
    env: {
        es6: true,
        node: true,
    },
    rules: {
        "no-dupe-class-members": "off",
        "no-var": "warn",
        "prefer-const": "warn",
        "no-constant-condition": ["warn", { checkLoops: false }],
        "no-unused-vars": "off",
        "@typescript-eslint/no-unused-vars": ["warn"],
        indent: "off",
        "no-multiple-empty-lines": "off",
        "space-in-parens": "off",
        "prettier/prettier": [
        "warn",
        {
            semi: true,
            trailingComma: "all",
            singleQuote: false,
            printWidth: 150,
            tabWidth: 2,
        },
        ],
        "no-case-declarations": "off",
        "@typescript-eslint/naming-convention": [
        "warn",
        {
            "selector": "typeLike",
            "format": ["PascalCase"]
        },
        {
            "selector": "enumMember",
            "format": ["UPPER_CASE"]
        },
        {
            "selector": "typeParameter",
            "format": ["PascalCase"]
        },
        {
            "selector": "variableLike",
            "format": ["camelCase"]
        },
        {
            "selector": "function",
            "format": ["camelCase"]
        },
        {
            "selector": "method",
            "format": ["camelCase"]
        },
        {
            "selector": "property",
            "format": ["camelCase"]
        },
        ]
        
    },
};
