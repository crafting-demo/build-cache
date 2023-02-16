# Sandbox Using Build Cache

## How it works

Run one builder sandbox which periodically builds cache from latest code.
New sandboxes are created by directly unpacking the latest build cache.

## Setup

Create the builder sandbox using:

```sh
cs sandbox create cache-builder --from=def:builder/template.yaml
```

Create the Template for day-to-day development use:

```sh
cs template create intellij-community dev/template.yaml
```

## Start a Sandbox

When the first cache is ready, create a sandbox from the `intellij-community` Template.
