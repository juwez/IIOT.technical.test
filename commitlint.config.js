module.exports = {
    extends: ['@commitlint/config-conventional'],
    rules: {
        'type-enum': [2, 'always', ['feat', 'enhance', 'fix', 'docs', 'style', 'refactor', 'test', 'chore']],
        'subject-case': [0, 'always', 'sentence-case'],
        'subject-full-stop': [0, 'never'],
        'header-max-length': [0, 'always', Infinity]
    }
};
