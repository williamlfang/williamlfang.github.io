# (grok)Best Practice for Writing Bash Scripts


&gt; what is the best practice for writing bash scripts

&lt;!--more--&gt;

Writing robust and maintainable Bash scripts requires following best practices to ensure readability, reliability, and portability. Below are key guidelines:

### 1. **Use a Shebang**
   - Start your script with `#!/bin/bash` (or `#!/usr/bin/env bash` for portability) to specify the interpreter.
   - Example:
     ```bash
     #!/usr/bin/env bash
     ```

### 2. **Enable Strict Mode**
   - Use `set` commands to catch errors early:
     - `set -e`: Exit on error.
     - `set -u`: Exit on unset variables.
     - `set -o pipefail`: Ensure pipelines fail if any command fails.
   - Example:
     ```bash
     set -euo pipefail
     ```

### 3. **Add Comments and Documentation**
   - Comment your code to explain its purpose and logic, especially for complex sections.
   - Include a header with script purpose, usage, and author info.
   - Example:
     ```bash
     # Purpose: Backup user data to a specified directory
     # Usage: ./backup.sh &lt;source&gt; &lt;destination&gt;
     # Author: Jane Doe, 2025
     ```

### 4. **Use Meaningful Variable Names**
   - Choose descriptive, lowercase variable names (e.g., `source_dir` instead of `sd`).
   - Use `readonly` for constants and `local` for variables in functions.
   - Example:
     ```bash
     readonly BACKUP_DIR=&#34;/backup&#34;
     local file_count=0
     ```

### 5. **Quote Variables and Strings**
   - Always quote variables to prevent issues with unset or empty variables and word splitting.
   - Example:
     ```bash
     cp &#34;$source&#34; &#34;$destination&#34;
     ```

### 6. **Avoid Unnecessary Subshells**
   - Use built-in Bash constructs instead of external commands (e.g., `[[ ]]` for tests instead of `[ ]`).
   - Prefer `read` over `echo | grep` for parsing.
   - Example:
     ```bash
     if [[ -d &#34;$dir&#34; ]]; then
         echo &#34;Directory exists&#34;
     fi
     ```

### 7. **Handle Errors Gracefully**
   - Check command exit statuses and provide meaningful error messages.
   - Use `trap` to clean up resources on script exit.
   - Example:
     ```bash
     trap &#39;echo &#34;Error on line $LINENO&#34;; exit 1&#39; ERR
     ```

### 8. **Write Modular Code**
   - Use functions to organize code and improve reusability.
   - Keep functions small and focused on a single task.
   - Example:
     ```bash
     log_message() {
         local message=&#34;$1&#34;
         echo &#34;[$(date)] $message&#34; &gt;&gt; &#34;$LOG_FILE&#34;
     }
     ```

### 9. **Validate Inputs**
   - Check for required arguments and validate input data.
   - Exit with clear error messages if validation fails.
   - Example:
     ```bash
     if [[ $# -ne 2 ]]; then
         echo &#34;Usage: $0 &lt;source&gt; &lt;destination&gt;&#34;
         exit 1
     fi
     ```

### 10. **Use Consistent Formatting**
   - Follow a style guide (e.g., indent with 2 or 4 spaces, avoid tabs).
   - Break long lines for readability (use `\` or wrap in functions).
   - Example:
     ```bash
     if [[ -n &#34;$variable&#34; ]]; then
         echo &#34;Variable is set&#34;
     else
         echo &#34;Variable is unset&#34;
     fi
     ```

### 11. **Test Your Scripts**
   - Test scripts in different environments to ensure portability.
   - Use tools like `shellcheck` to catch common errors and improve quality.
   - Example:
     ```bash
     shellcheck myscript.sh
     ```

### 12. **Avoid Hardcoding Paths**
   - Use variables or relative paths to make scripts portable.
   - Example:
     ```bash
     SCRIPT_DIR=&#34;$(dirname &#34;$0&#34;)&#34;
     source &#34;${SCRIPT_DIR}/config.sh&#34;
     ```

### 13. **Log Output**
   - Redirect output to log files for debugging and auditing.
   - Use `tee` to log to both file and stdout.
   - Example:
     ```bash
     echo &#34;Starting backup&#34; | tee -a &#34;$LOG_FILE&#34;
     ```

### 14. **Use Modern Constructs**
   - Prefer `[[ ]]` over `[ ]` for conditionals (more robust, supports regex).
   - Use `$( )` instead of `` ` ` `` for command substitution (better nesting).
   - Example:
     ```bash
     if [[ &#34;$name&#34; =~ ^[a-z]&#43;$ ]]; then
         echo &#34;Valid name&#34;
     fi
     ```

### 15. **Secure Your Scripts**
   - Avoid exposing sensitive data (e.g., passwords) in scripts.
   - Use environment variables or secure vaults for secrets.
   - Set appropriate file permissions (`chmod 700 script.sh`).
   - Example:
     ```bash
     if [[ -z &#34;${DB_PASSWORD:-}&#34; ]]; then
         echo &#34;DB_PASSWORD not set&#34;
         exit 1
     fi
     ```

### 16. **Exit Codes**
   - Use consistent exit codes (e.g., `0` for success, `1` for general errors).
   - Document custom exit codes in the script header.
   - Example:
     ```bash
     exit 0  # Success
     ```

### 17. **Profile and Optimize**
   - Use `time` or debugging tools to identify slow sections.
   - Avoid unnecessary loops or external commands.
   - Example:
     ```bash
     time ./myscript.sh
     ```

### Example Script Incorporating Best Practices
```bash
#!/usr/bin/env bash

# Purpose: Copy files from source to destination with logging
# Usage: ./copy.sh &lt;source&gt; &lt;destination&gt;
# Author: Jane Doe, 2025

set -euo pipefail

# Constants
readonly LOG_FILE=&#34;/var/log/copy.log&#34;
readonly MAX_FILES=1000

# Functions
log_message() {
    local message=&#34;$1&#34;
    echo &#34;[$(date)] $message&#34; | tee -a &#34;$LOG_FILE&#34;
}

validate_inputs() {
    local source=&#34;$1&#34;
    local destination=&#34;$2&#34;
    if [[ ! -d &#34;$source&#34; ]]; then
        log_message &#34;Error: Source directory does not exist&#34;
        exit 1
    fi
    if [[ ! -d &#34;$destination&#34; ]]; then
        log_message &#34;Creating destination directory: $destination&#34;
        mkdir -p &#34;$destination&#34;
    fi
}

# Main
if [[ $# -ne 2 ]]; then
    echo &#34;Usage: $0 &lt;source&gt; &lt;destination&gt;&#34;
    exit 1
fi

source_dir=&#34;$1&#34;
dest_dir=&#34;$2&#34;

validate_inputs &#34;$source_dir&#34; &#34;$dest_dir&#34;

log_message &#34;Starting copy from $source_dir to $dest_dir&#34;

file_count=0
while IFS= read -r -d &#39;&#39; file; do
    cp &#34;$file&#34; &#34;$dest_dir/&#34;
    ((file_count&#43;&#43;))
    if [[ $file_count -ge $MAX_FILES ]]; then
        log_message &#34;Error: Maximum file limit reached&#34;
        exit 2
    fi
done &lt; &lt;(find &#34;$source_dir&#34; -type f -print0)

log_message &#34;Copy completed. $file_count files copied.&#34;
exit 0
```

### Additional Tools and Resources
- **ShellCheck**: Static analysis tool for catching syntax and logical errors (`shellcheck myscript.sh`).
- **Bash Style Guide**: Follow Google’s Shell Style Guide or similar for consistency.
- **Testing Frameworks**: Use `bats` for unit testing Bash scripts.

By adhering to these practices, your Bash scripts will be more reliable, easier to maintain, and less prone to errors. Let me know if you need help with a specific script or tool!


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-04-16-grokbest-practice-for-writing-bash-scripts/  

