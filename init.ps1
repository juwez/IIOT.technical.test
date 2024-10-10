# Add npm global bin directory to PATH
$npmBinPath = npm bin -g
$env:PATH = "$npmBinPath;$env:PATH"

# Function to check if Node.js and npm are installed
function checkNodeNpm {
    try {
        $nodeCheck = & node -v
        $npmCheck = & npm -v
        if ($nodeCheck -and $npmCheck) {
            Write-Host "Node.js and npm are installed."
        }
        else {
            Write-Host "Node.js and npm are not installed. Please install them first."
            exit 1
        }
    }
    catch {
        Write-Host "Node.js and npm are not installed. Please install them first."
        exit 1
    }
}
function createLaunchProfiles {
    param (
        [string]$repoType
    )
    New-Item -ItemType Directory -Path ".vscode" -Force
    if ($repoType -eq "monorepo") {
        $launchJsonContent = @'

{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "node",
            "request": "launch",
            "name": "Launch Program",
            "skipFiles": ["<node_internals>/**"],
            "program": "${workspaceFolder}/packages/your-package/src/index.ts",
            "preLaunchTask": "tsc: build - tsconfig.json",
            "outFiles": ["${workspaceFolder}/packages/your-package/dist/**/*.js"],
            "cwd": "${workspaceFolder}/packages/your-package/",
            "console": "integratedTerminal",
            "internalConsoleOptions": "neverOpen",
            "envFile": "${workspaceFolder}/packages/your-package/.env"

        }
    ]
}
'@

        $taskContent = @'
{
    "version": "2.0.0",
    "tasks": [
        {
            "type": "npm",
            "script": "build",
            "path": "packages/your-package",
            "group": "build",
            "problemMatcher": [],
            "label": "npm: build - packages/your-package",
            "detail": "tsc"
        },
    ]
}
'@
    }
    else {
        $launchJsonContent = @'
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "node",
            "request": "launch",
            "name": "launch program",
            "program": "${workspaceFolder}/src/index.ts",
            "preLaunchTask": "tsc: build - tsconfig.json",
            "outFiles": [
                "${workspaceFolder}/dist/**/*.js"
            ],
            "skipFiles": ["<node_internals>/**"],
            "cwd": "${workspaceFolder}/src/",
            "console": "integratedTerminal",
            "internalConsoleOptions": "neverOpen",
            "envFile": "${workspaceFolder}/.env"
        }
    ]
}
'@

        $taskContent = @'
{
    "version": "2.0.0",
    "tasks": [
        {
            "type": "npm",
            "script": "build",
            "group": "build",
            "problemMatcher": [],
            "label": "npm: build",
            "detail": "npm run build"
        }
    ]
}
'@
    }
    # Write content to files
    Set-Content -Path ".vscode/launch.json" -Value $launchJsonContent -ErrorAction Stop
    Set-Content -Path ".vscode/tasks.json" -Value $taskContent -ErrorAction Stop

    Write-Host "launch.json file created in .vscode directory."
}




# Function to create .gitignore file
function createGitignore {
    try {
        New-Item -ItemType File -Path ".gitignore" -Force
        $gitignoreContent = "node_modules/"
        Set-Content -Path ".gitignore" -Value $gitignoreContent -ErrorAction Stop
        Write-Host ".gitignore file created."
    }
    catch {
        Write-Host "Failed to create .gitignore file: $_"
        exit 1
    }
}

# Function to append configurations to package.json
function editJson {
    param (
        [string]$jsonToAdd,
        [string]$file
    )
    try { 
        json -I -f $file -e $jsonToAdd
    }
    catch {
        Write-Host "Failed to append to package.json: $_"
        exit 1
    }
}

# Function to create an .nvmrc file
function createNvmrc {
    param (
        [string]$directory
    )
    try {
        $nodeVersion = & node -v
        $nvmrcPath = Join-Path -Path $directory -ChildPath ".nvmrc"
        Set-Content -Path $nvmrcPath -Value $nodeVersion
        Write-Host ".nvmrc file created in $directory with Node.js version $nodeVersion."
    }
    catch {
        Write-Host "Failed to create .nvmrc file: $_"
        exit 1
    }
}

# Function to prompt for language selection
function selectLanguage {
    $languageOptions = @("TypeScript", "Python")
    Write-Host "Select the language you want:"
    for ($i = 0; $i -lt $languageOptions.Length; $i++) {
        Write-Host "$($i + 1). $($languageOptions[$i])"
    }
    $languageSelection = Read-Host "Enter the number of your selection"
    
    switch ($languageSelection) {
        1 { return $languageOptions[0] }
        2 { return $languageOptions[1] }
        default { 
            Write-Host "Invalid selection. Please try again."
            selectLanguage
        }
    }
}

# Function to prompt for repository setup selection
function selectRepoType {
    Write-Host "Do you want to use a monorepo? (y/n)"
    $response = Read-Host
    switch ($response.ToLower()) {
        "y" { return $true }
        "n" { return $false }
        default {
            Write-Host "Invalid input. Please enter 'y' or 'n'."
            selectRepoType
        }
    }
}

function collectRepoInfo {
    $packages = @()
    do {
        $packageName = Read-Host "Enter the package name (leave blank and press Enter when done)"
        if ($packageName -ne "") {
            $packages += $packageName
        }
    } while ($packageName -ne "")
    return $packages
}

# Function to create folder structure for monorepo
function createMonorepoStructure {
    param (
        [array]$packages
    )
    # Create 'packages' directory
    New-Item -ItemType Directory -Path "packages" -Force

    # Create package directories and initialize npm and install TypeScript
    foreach ($package in $packages) {    
        $packagePath = "packages/$package"
        New-Item -ItemType Directory -Path $packagePath -Force
        New-Item -ItemType Directory -Path "$packagePath/src" -Force
        New-Item -ItemType Directory -Path "$packagePath/tests" -Force
        New-Item -ItemType File -Path "$packagePath/.eslintrc.js" -Force
        New-Item -ItemType File -Path "$packagePath/.eslintignore" -Force
        New-Item -ItemType File -Path "$packagePath/src/index.ts" -Force
        Set-Content -Path "$packagePath/src/index.ts" -Value @"
        console.log('Hello, World!');
"@
        New-Item -ItemType File -Path "$packagePath/.prettierrc.js" -Force


        Set-Content -Path "$packagePath/.prettierrc.js" -Value @"
module.exports = {
    semi: true,
    trailingComma: 'all',
    singleQuote: false,
    printWidth: 150,
    tabWidth: 2,
    endOfLine: 'crlf',
    plugins: ["prettier-plugin-organize-imports"],
};
"@

        Set-Content -Path "$packagePath/.eslintrc.js" -Value @"
module.exports = {
    parser: "@typescript-eslint/parser",
    globals: {
    },
    extends: ["plugin:prettier/recommended", "prettier", "eslint:recommended"],
    plugins: ["@typescript-eslint", "only-warn"],
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
"@

        Set-Location -Path $packagePath
        npm init -y
        tsc --init

        npm install typescript --save-dev
        json -I -f package.json -e "this.scripts.lint='eslint src/**/*.ts --fix'"
        npm install --save-dev eslint-plugin-only-warn eslint-config-prettier  @typescript-eslint/eslint-plugin eslint-plugin-prettier prettier prettier-plugin-organize-imports prettier-eslint prettier
        Set-Location -Path "../.."
    }

    Write-Host "Monorepo folder structure and packages created successfully."
}
function createStandardRepo {
    
    # Create project structure
    New-Item -ItemType Directory -Path "src" -Force
    New-Item -ItemType Directory -Path "tests" -Force

    # Create ESLint configuration
    New-Item -ItemType File -Path ".eslintrc.js" -Force
    New-Item -ItemType File -Path ".eslintignore" -Force
    New-Item -ItemType File -Path "src/index.ts" -Force
    Set-Content -Path "src/index.ts" -Value @"
    console.log('Hello, World!');
"@
    Set-Content -Path ".eslintrc.js" -Value @"
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
"@
    Set-Content -Path ".prettierrc.js" -Value @"
module.exports = {
semi: true,
trailingComma: 'all',
singleQuote: false,
printWidth: 150,
tabWidth: 2,
endOfLine: 'crlf',
plugins: ["prettier-plugin-organize-imports"],
};
"@

    npm install --save-dev eslint-plugin-only-warn eslint-config-prettier  @typescript-eslint/eslint-plugin eslint-plugin-prettier prettier-plugin-organize-imports prettier-eslint prettier
    json -I -f package.json -e "this.scripts.lint='eslint src/**/*.ts --fix'"
    Write-Host "Standard repository structure created."
}


# Function to commit changes with git
function commitChanges {
    param([string]$message)

    git add .
    git commit -m $message
    git push
}

# Main script execution

# Select language
$selectedLanguage = selectLanguage

if ($selectedLanguage -eq "TypeScript") {
    # Check if Node.js and npm are installed
    checkNodeNpm

    # Create .gitignore file
    createGitignore

    # Commit initial changes (add .gitignore)
#    commitChanges -message "chore(): add gitignore"

    # Create .nvmrc file
    createNvmrc -directory $PWD

    # Create commitlint.config.js
    New-Item -ItemType File -Path "commitlint.config.js" -Force
    Set-Content -Path "commitlint.config.js" -Value @"
module.exports = {
    extends: ['@commitlint/config-conventional'],
    rules: {
        'type-enum': [2, 'always', ['feat', 'enhance', 'fix', 'docs', 'style', 'refactor', 'test', 'chore']],
        'subject-case': [0, 'always', 'sentence-case'],
        'subject-full-stop': [0, 'never'],
        'header-max-length': [0, 'always', Infinity]
    }
};
"@

    # Append configurations to package.json
    $monoRepo = selectRepoType
    if ($monoRepo -eq $true) {   
        npm install --save-dev @commitlint/cli @commitlint/config-conventional lint-staged husky@4 eslint@8.57.0 prettier-eslint prettier prettier-plugin-organize-imports lerna
        npm install -g json
        npm install -g typescript

        tsc --init 

        editJson -file "package.json" -jsonToAdd  "this['lint-staged']={'packages/*/*.{ts,tsx}':['npm run lint', 'git add']}"
        editJson -file "package.json" -jsonToAdd "this.husky={hooks:{'commit-msg':'commitlint -E HUSKY_GIT_PARAMS', 'pre-commit':'lint-staged'}}"
        # Collect package names for monorepo
        $packages = collectRepoInfo
        createLaunchProfiles -repoType "monorepo"
        createMonorepoStructure -packages $packages
    }
    else {
        npm init -y
        tsc --init 
        npm install --save-dev @commitlint/cli @commitlint/config-conventional lint-staged husky@4 eslint@8.57.0 prettier-eslint prettier prettier-plugin-organize-imports  
        npm install -g typescript
        npm install -g json

        editJson -file "package.json" -jsonToAdd  "this['lint-staged']={'*.{ts,tsx}':['npm run lint', 'git add']}"
        editJson -file "package.json" -jsonToAdd "this.husky={hooks:{'commit-msg':'commitlint -E HUSKY_GIT_PARAMS', 'pre-commit':'lint-staged'}}" 
        editJson -file "package.json" -jsonToAdd "this.main=''"
        editJson -file "package.json" -jsonToAdd "this.description=''"
        createLaunchProfiles -repoType ""
        createStandardRepo
    }
    npm uninstall -g json

}

# Depending on the selected language and repository type, execute the corresponding action
else {
    Write-Host "Not yet implemented."
}
