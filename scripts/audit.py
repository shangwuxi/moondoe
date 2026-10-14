"""Read-only source-scale and test inventory; no generated/fixture/example counting."""
from pathlib import Path
import json
import re
import subprocess

root = Path(__file__).resolve().parent.parent
source = sorted(p for p in root.glob("*.mbt")
                if not p.name.endswith(("_test.mbt", "_wbtest.mbt")))
lines = {p.name: len(p.read_text(encoding="utf-8").splitlines()) for p in source}
# Match named tests directly; multiline bodies do not affect the count.
tests = sum(len(re.findall(r'^test ', p.read_text(encoding="utf-8"), re.M))
            for p in root.glob("*_wbtest.mbt"))
commits = int(subprocess.check_output(["git", "rev-list", "--count", "HEAD"], cwd=root, text=True))
report = {"production_physical_lines": sum(lines.values()), "files": lines,
          "named_whitebox_tests": tests, "raw_commits": commits,
          "exclusions": "tests, examples, generated interfaces, docs, configs, scripts; root production .mbt only"}
print(json.dumps(report, indent=2, ensure_ascii=False))
if report["production_physical_lines"] < 1500 or tests < 38:
    raise SystemExit("source or test threshold regressed")
