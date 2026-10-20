# public-release-notes

Strips internal links from release notes before they are published to a public
repository, and fails if any are left. By default it removes the
`[[sc-NNNN]](https://app.shortcut.com/...)` prefixes that `cliff.toml` adds to
changelog lines, then fails on any remaining `shortcut.com` link.

Works alongside the changelog actions suite:
`changelog-generate` → `changelog-merge` → `changelog-release` → `changelog-notify`.

## Usage

```yaml
- uses: mindsers/changelog-reader-action@v2
  id: changelog_reader
  with:
    validation_level: none
    version: ${{ github.event.release.tag_name }}
    path: ./CHANGELOG.md

- uses: uptick-dev/public-release-notes@v1
  id: public_notes
  with:
    changes: ${{ steps.changelog_reader.outputs.changes }}

- run: echo "$NOTES"
  env:
    NOTES: ${{ steps.public_notes.outputs.changes }}
```

## Inputs

| Name | Default | Description |
| --- | --- | --- |
| `changes` | _(required)_ | Release notes markdown. |
| `strip-pattern` | Shortcut `[[sc-N]](...)` link | Extended regex (`sed -E`) removed from the notes. Must not contain `#`. |
| `forbid-pattern` | `shortcut\.com` | Extended regex (`grep -Ei`) that fails the step if it still matches. Empty disables the check. |

## Outputs

| Name | Description |
| --- | --- |
| `changes` | The notes with internal links removed. |

## Development

```sh
bash test/strip_test.sh
```
