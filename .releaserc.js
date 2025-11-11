module.exports = {
  branches: [
    'main',
    {
      name: 'develop',
      prerelease: 'beta'
    }
  ],
  plugins: [
    [
      '@semantic-release/commit-analyzer',
      {
        preset: 'angular',
        releaseRules: [
          // Custom rules for PR-based workflow
          { breaking: true, release: 'major' },
          { type: 'feat', release: 'minor' },
          { type: 'fix', release: 'patch' },
          { type: 'perf', release: 'patch' },
          { type: 'revert', release: 'patch' },
          { type: 'docs', scope: 'README', release: 'patch' },
          { type: 'style', release: false },
          { type: 'chore', release: false },
          { type: 'refactor', release: false },
          { type: 'test', release: false },
          { type: 'build', release: false },
          { type: 'ci', release: false }
        ],
        parserOpts: {
          noteKeywords: ['BREAKING CHANGE', 'BREAKING CHANGES', 'BREAKING']
        }
      }
    ],
    [
      '@semantic-release/release-notes-generator',
      {
        preset: 'angular',
        presetConfig: {
          types: [
            { type: 'feat', section: 'Features' },
            { type: 'fix', section: 'Bug Fixes' },
            { type: 'perf', section: 'Performance Improvements' },
            { type: 'revert', section: 'Reverts' },
            { type: 'docs', section: 'Documentation' },
            { type: 'style', section: 'Styles', hidden: true },
            { type: 'chore', section: 'Chores', hidden: true },
            { type: 'refactor', section: 'Code Refactoring', hidden: true },
            { type: 'test', section: 'Tests', hidden: true },
            { type: 'build', section: 'Build System', hidden: true },
            { type: 'ci', section: 'Continuous Integration', hidden: true }
          ]
        }
      }
    ],
    [
      '@semantic-release/npm',
      {
        npmPublish: false
      }
    ],
    [
      '@semantic-release/github',
      {
        assets: [],
        successComment: "This PR is included in version [${nextRelease.version}](${nextRelease.gitTag}) which has been released! The release is available on:\n- [GitHub Releases](${nextRelease.gitTag})\n- [Container Registry](https://gallery.ecr.aws/liatrio-demo/api:v${nextRelease.version})\n\nYour changes are now live!",
        failComment: "The release process failed. Please check the [build logs](${env.GITHUB_SERVER_URL}/${env.GITHUB_REPOSITORY}/actions/runs/${env.GITHUB_RUN_ID}) for more information."
      }
    ]
  ]
};