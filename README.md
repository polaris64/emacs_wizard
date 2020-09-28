# emacs_wizard.el

This is a prototype intended to demonstrate how an Emacs set-up wizard could be implemented.

# How to use

This is intended to be run with a fresh install of Emacs. To simulate this, run the following in your shell, substituting the correct path to where emacs_wizard.el is located: -

```shell
emacs -q -l emacs_wizard.el
```

# Progress

Currently the library provides a two-step wizard for generating a configuration (`init.el`) for the user based on their choices. It does not actually generate a useful configuration, it merely demonstrates how this would be done.

After generating the configuration file, the wizard provides a button which saves it to the user's configuration directory (`~/.emacs.d/`). To avoid overwriting a real `init.el` file, this prototype saves the file instead to `init.el.wizard`. A real version would of course save to `init.el` and make backups as necessary.
