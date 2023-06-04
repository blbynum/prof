# prof - Bash Profile Manager

`prof` is a command-line tool for managing bash profiles. It allows you to organize and manage custom `.bash_profile` contents by creating and editing profiles, setting load order, exporting and importing profiles, and more.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Commands](#commands)
- [Examples](#examples)

## Installation

To install `prof`, you can follow these steps:

1. Download the latest release of `prof` from the [GitHub release page](https://github.com/blbynum/prof/releases).


2. Make the `prof` file executable:

   ```shell
   chmod +x prof
   ```

3. (Optional) Copy the `prof` file to a directory in your PATH to make it globally accessible:

   ```shell
   cp prof /usr/local/bin
   ```

Now you're ready to use `prof`!

## Usage

To use `prof`, you can run the following command:

```shell
prof <command> [arguments]
```

For detailed information on available commands and their usage, you can refer to the [Commands](#commands) section below.

## Commands

### create <profile_name> <load_order>

Creates a new profile with the specified name and load order.

```shell
prof create <profile_name> <load_order>
```

### edit <profile_name>

Opens an existing profile in your preferred text editor for editing.

```shell
prof edit <profile_name>
```

### delete <profile_name>

Deletes an existing profile. This action is irreversible.

```shell
prof delete <profile_name>
```

### list

Lists all available profiles along with their load order.

```shell
prof list
```

### export <profile_name> <export_directory>

Exports a profile to the specified export directory.

```shell
prof export <profile_name> <export_directory>
```

### import <profile_file> <load_order>

Imports a profile from the specified file with the specified load order.

```shell
prof import <profile_file> <load_order>
```

### install [target_file]

Installs `prof` by adding the code to load profiles to the target file (`~/.bash_profile` by default).

```shell
prof install [target_file]
```

### help

Displays the help message with information on available commands.

```shell
prof help
```

## Examples

Here are some examples of how you can use `prof`:

1. Create a new profile named "work" with a load order of 10:

   ```shell
   prof create work 10
   ```

2. Edit an existing profile named "personal":

   ```shell
   prof edit personal
   ```

3. Delete a profile named "old" (with confirmation prompt):

   ```shell
   prof delete old
   ```

4. List all available profiles:

   ```shell
   prof list
   ```

5. Export a profile named "dev" to the "~/exports" directory:

   ```shell
   prof export dev ~/exports
   ```

6. Import a profile from a file named "myprofile" with a load order of 5:

   ```shell
   prof import myprofile 5
   ```

7. Install `prof` by adding the code to load profiles to a custom target file:

   ```shell
   prof install ~/.bashrc
   ```

For more details on each command and its usage, refer to the
[Usage](#usage) section above.

---

## Upgrading from v1.0.0

Upgrade Instructions:
1. Download the latest release from the [GitHub repository](https://github.com/your_username/prof/releases).
2. Replace your existing prof file with the new version.
3. Update your existing profiles to include the new loading message by running the following script:
   - Download the migration script from [this link](https://github.com/blbynum/prof/blob/release/1.1.0/resources/profiles_migration_1.1.0.sh).
   - Open a terminal and navigate to the directory where you downloaded the script.
   - Make the script executable with the command: `chmod +x profiles_migration_1.1.0.sh`.
   - Run the script with the command: `./profiles_migration_1.1.0.sh`.
   - The script will add the loading message to each existing profile that does not already contain it.

---

