import os

with open("gpt-code-index.txt", "w") as out:
    for root, dirs, files in os.walk("."):
        for file in files:
            if file.endswith((".py", ".md", ".txt")) and "venv" not in root:
                path = os.path.join(root, file)
                out.write(f"\n\n===== {path} =====\n\n")
                with open(path, "r", errors="ignore") as f:
                    out.write(f.read())
