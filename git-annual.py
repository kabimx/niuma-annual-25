#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Git Annual Summary Generator
Generate a beautiful HTML report showing your 2025 Git contributions
"""

import subprocess
import os
import sys
import locale
import webbrowser
from datetime import datetime

CURRENT_YEAR = 2025

def detect_language():
    """Detect system language"""
    lang = locale.getdefaultlocale()[0] or ""
    if lang.startswith("zh"):
        return "zh"
    return "en"

CURRENT_LANG = detect_language()

# i18n texts
if CURRENT_LANG == "zh":
    MSG = {
        "INFO": "[信息]",
        "ERROR": "[错误]",
        "WELCOME": "Git 年度总结生成器",
        "NOT_GIT_REPO": "不是 Git 仓库",
        "FOUND_REPO": "找到 Git 仓库",
        "COLLECTING": "正在收集 {} 年的统计数据...",
        "STATS_COLLECTED": "统计数据收集完成！",
        "GENERATING": "正在生成 HTML 报告...",
        "DONE": "完成！🎉",
        "OPENING": "正在打开报告...",
    }
    HTML = {
        "TITLE": "年度Git工作总结",
        "HEADER": "年度 Git 总结",
        "THANKS": "感谢",
        "COMMITS": "提交次数",
        "WEEKLY_COMMITS": "每周提交",
        "LINES_ADDED": "新增行数",
        "LINES_DELETED": "删除行数",
        "DAILY_LINES": "日均代码量",
        "ACTIVE_DAYS": "活跃天数",
        "WORKDAY_RATIO": "工作日占比",
        "FIRST_COMMIT": "首次提交",
        "LAST_COMMIT": "最后提交",
        "EARLIEST_TIME": "最早提交时间",
        "LATEST_TIME": "最晚提交时间",
        "NIU_INDEX": "牛指数",
        "MA_INDEX": "马指数",
        "GENERATED": "生成时间",
        "NONE": "无",
    }
    NIU = ["小牛(1/4)", "壮牛(2/4)", "猛牛(3/4)", "神牛(4/4)"]
    MA = ["小马(1/4)", "快马(2/4)", "烈马(3/4)", "神马(4/4)"]
    SUMMARY = {
        "GOD": "神中神！生产队的驴看了都自愧不如 🏆",
        "CODE_MANIAC": "代码狂魔！生产队的驴都没你能写 💪",
        "COMMIT_MANIAC": "提交狂人！键盘都要被你敲冒烟了 🔥",
        "NIUMA": "牛马本马！两眼一睁干到熄灯 🐂🐴",
        "STEADY": "稳扎稳打，打工人的标准姿态 👔",
        "CHILL": "佛系打工，只要心态好 🏝️",
        "DEFAULT": "条条大路当牛马，感谢努力的自己 ✨",
    }
else:
    MSG = {
        "INFO": "[INFO]",
        "ERROR": "[ERROR]",
        "WELCOME": "Git Annual Summary Generator",
        "NOT_GIT_REPO": "Not a git repository",
        "FOUND_REPO": "Found git repository",
        "COLLECTING": "Collecting statistics for year {}...",
        "STATS_COLLECTED": "Statistics collected!",
        "GENERATING": "Generating HTML report...",
        "DONE": "Done! 🎉",
        "OPENING": "Opening report...",
    }
    HTML = {
        "TITLE": "Git Annual Summary",
        "HEADER": "Git Annual Summary",
        "THANKS": "Thanks for",
        "COMMITS": "Commits",
        "WEEKLY_COMMITS": "Weekly Commits",
        "LINES_ADDED": "Lines Added",
        "LINES_DELETED": "Lines Deleted",
        "DAILY_LINES": "Daily Lines",
        "ACTIVE_DAYS": "Active Days",
        "WORKDAY_RATIO": "Workday Ratio",
        "FIRST_COMMIT": "First Commit",
        "LAST_COMMIT": "Last Commit",
        "EARLIEST_TIME": "Earliest Time",
        "LATEST_TIME": "Latest Time",
        "NIU_INDEX": "Niu Index",
        "MA_INDEX": "Ma Index",
        "GENERATED": "Generated at",
        "NONE": "N/A",
    }
    NIU = ["Calf (1/4)", "Bull (2/4)", "Mighty (3/4)", "Legend (4/4)"]
    MA = ["Pony (1/4)", "Racer (2/4)", "Stallion (3/4)", "Legend (4/4)"]
    SUMMARY = {
        "GOD": "You're the GOAT! Built different, no cap 🏆",
        "CODE_MANIAC": "10x Developer detected! Leetcode fears you 💪",
        "COMMIT_MANIAC": "Git push speedrunner! Any% world record 🔥",
        "NIUMA": "Sigma grindset activated! Rise and grind 🐂🐴",
        "STEADY": "Solid 9-to-5 energy. Corporate wants you 👔",
        "CHILL": "Quiet quitting? Nah, smart working 🏝️",
        "DEFAULT": "Touched grass AND wrote code. Respect ✨",
    }


# Color output
class Colors:
    GREEN = "\033[92m"
    RED = "\033[91m"
    CYAN = "\033[96m"
    END = "\033[0m"


def print_info(msg):
    print(f"{Colors.GREEN}{MSG['INFO']}{Colors.END} {msg}")


def print_error(msg):
    print(f"{Colors.RED}{MSG['ERROR']}{Colors.END} {msg}")


def show_welcome():
    print()
    print(f"{Colors.CYAN}========================================{Colors.END}")
    print(f"{Colors.CYAN}    {MSG['WELCOME']}{Colors.END}")
    print(f"{Colors.CYAN}           V2 (Python){Colors.END}")
    print(f"{Colors.CYAN}========================================{Colors.END}")
    print()


def run_git(args, cwd=None):
    """Run git command and return output"""
    try:
        result = subprocess.run(
            ["git"] + args,
            cwd=cwd,
            capture_output=True,
            text=True,
            encoding="utf-8",
        )
        return result.stdout.strip()
    except Exception:
        return ""


def validate_git_repo(path):
    """Check if path is a git repository"""
    git_dir = os.path.join(path, ".git")
    if not os.path.isdir(git_dir):
        print_error(f"{MSG['NOT_GIT_REPO']}: {path}")
        sys.exit(1)
    print_info(f"{MSG['FOUND_REPO']}: {path}")


def get_git_user(path):
    """Get git user name"""
    user = run_git(["config", "user.name"], cwd=path)
    if not user:
        user = run_git(["config", "--global", "user.name"], cwd=path)
    return user


def collect_stats(path, author):
    """Collect git statistics"""
    print_info(MSG["COLLECTING"].format(CURRENT_YEAR))

    start_date = f"{CURRENT_YEAR}-01-01"
    end_date = f"{CURRENT_YEAR}-12-31"

    author_arg = [f"--author={author}"] if author else []

    # Commit count
    commits = run_git(
        ["log"] + author_arg + [f"--since={start_date}", f"--until={end_date}", "--oneline"],
        cwd=path
    )
    commit_count = len(commits.splitlines()) if commits else 0

    # Commits per week
    commits_per_week = round(commit_count / 52, 1)

    # Lines added/deleted
    stats = run_git(
        ["log"] + author_arg + [f"--since={start_date}", f"--until={end_date}", "--numstat", "--pretty=format:"],
        cwd=path
    )
    lines_added = 0
    lines_deleted = 0
    if stats:
        for line in stats.splitlines():
            parts = line.split()
            if len(parts) >= 2 and parts[0].isdigit() and parts[1].isdigit():
                lines_added += int(parts[0])
                lines_deleted += int(parts[1])

    # Active days
    dates = run_git(
        ["log"] + author_arg + [f"--since={start_date}", f"--until={end_date}", "--format=%ad", "--date=short"],
        cwd=path
    )
    active_days = len(set(dates.splitlines())) if dates else 0

    # Workday ratio (248 workdays in 2025)
    workday_ratio = round(active_days * 100 / 248, 1)

    # Daily lines
    daily_lines = (lines_added + lines_deleted) // 248

    # Niu index
    if daily_lines < 50:
        niu_index, niu_level = NIU[0], 1
    elif daily_lines < 150:
        niu_index, niu_level = NIU[1], 2
    elif daily_lines < 300:
        niu_index, niu_level = NIU[2], 3
    else:
        niu_index, niu_level = NIU[3], 4

    # Ma index
    weekly_int = int(commits_per_week)
    if weekly_int < 3:
        ma_index, ma_level = MA[0], 1
    elif weekly_int < 6:
        ma_index, ma_level = MA[1], 2
    elif weekly_int < 15:
        ma_index, ma_level = MA[2], 3
    else:
        ma_index, ma_level = MA[3], 4

    # Summary
    if niu_level == 4 and ma_level == 4:
        summary_text = SUMMARY["GOD"]
    elif niu_level == 4:
        summary_text = SUMMARY["CODE_MANIAC"]
    elif ma_level == 4:
        summary_text = SUMMARY["COMMIT_MANIAC"]
    elif niu_level >= 3 and ma_level >= 3:
        summary_text = SUMMARY["NIUMA"]
    elif niu_level >= 2 and ma_level >= 2:
        summary_text = SUMMARY["STEADY"]
    elif niu_level <= 1 and ma_level <= 1:
        summary_text = SUMMARY["CHILL"]
    else:
        summary_text = SUMMARY["DEFAULT"]

    # First/Last commit dates
    first_commit = run_git(
        ["log"] + author_arg + [f"--since={start_date}", f"--until={end_date}", "--format=%ad", "--date=short", "--reverse"],
        cwd=path
    )
    first_commit = first_commit.splitlines()[0] if first_commit else HTML["NONE"]

    last_commit = run_git(
        ["log"] + author_arg + [f"--since={start_date}", f"--until={end_date}", "--format=%ad", "--date=short"],
        cwd=path
    )
    last_commit = last_commit.splitlines()[0] if last_commit else HTML["NONE"]

    # Earliest/Latest commit times
    times = run_git(
        ["log"] + author_arg + [f"--since={start_date}", f"--until={end_date}", "--format=%ad", "--date=format:%H:%M"],
        cwd=path
    )
    if times:
        time_list = []
        for t in times.splitlines():
            h, m = map(int, t.split(":"))
            mins = (h - 6) * 60 + m if h >= 6 else (h + 18) * 60 + m
            time_list.append((mins, t))
        time_list.sort()
        earliest_commit = time_list[0][1]
        latest_commit = time_list[-1][1]
    else:
        earliest_commit = HTML["NONE"]
        latest_commit = HTML["NONE"]

    repo_name = os.path.basename(path)
    print_info(MSG["STATS_COLLECTED"])

    return {
        "repo_name": repo_name,
        "commit_count": commit_count,
        "commits_per_week": commits_per_week,
        "lines_added": lines_added,
        "lines_deleted": lines_deleted,
        "daily_lines": daily_lines,
        "active_days": active_days,
        "workday_ratio": workday_ratio,
        "first_commit": first_commit,
        "last_commit": last_commit,
        "earliest_commit": earliest_commit,
        "latest_commit": latest_commit,
        "niu_index": niu_index,
        "ma_index": ma_index,
        "summary_text": summary_text,
    }


def generate_html(stats, output_file):
    """Generate HTML report"""
    print_info(MSG["GENERATING"])

    html_lang = "zh-CN" if CURRENT_LANG == "zh" else "en"
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    html_content = f'''<!DOCTYPE html>
<html lang="{html_lang}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{HTML["TITLE"]}</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }}
        .container {{ max-width: 900px; margin: 0 auto; }}
        .header {{ text-align: center; color: white; margin-bottom: 40px; }}
        .header h1 {{ font-size: 2.5rem; margin-bottom: 10px; text-shadow: 2px 2px 4px rgba(0,0,0,0.2); }}
        .header .subtitle {{ font-size: 1.2rem; opacity: 0.9; }}
        .cards {{ display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }}
        .card {{
            background: white;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            transition: transform 0.3s ease;
        }}
        .card:hover {{ transform: translateY(-5px); }}
        .card-icon {{ font-size: 2.5rem; margin-bottom: 12px; }}
        .card-value {{ font-size: 2.2rem; font-weight: 700; color: #333; margin-bottom: 8px; }}
        .card-label {{ font-size: 0.95rem; color: #666; text-transform: uppercase; letter-spacing: 1px; }}
        .footer {{ text-align: center; color: white; opacity: 0.8; font-size: 0.9rem; margin-top: 20px; }}
        .highlight {{ background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }}
        .highlight .card-value, .highlight .card-label {{ color: white; }}
        .summary {{
            text-align: center; margin: 40px 0; padding: 30px;
            background: white; border-radius: 16px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
        }}
        .summary-title {{ font-size: 2.5rem; font-weight: 700; color: #333; margin-bottom: 15px; }}
        .summary-text {{ font-size: 1.3rem; color: #666; }}
    </style>
</head>'''

    html_content += f'''
<body>
    <div class="container">
        <div class="header">
            <h1>🎉 {CURRENT_YEAR} {HTML["HEADER"]}</h1>
            <div class="subtitle">📁 {stats["repo_name"]}</div>
        </div>
        <div class="summary">
            <div class="summary-title">{HTML["THANKS"]} {CURRENT_YEAR} 🎊</div>
            <div class="summary-text">{stats["summary_text"]}</div>
        </div>'''

    html_content += f'''
        <div class="cards">
            <div class="card highlight">
                <div class="card-icon">📝</div>
                <div class="card-value">{stats["commit_count"]:,}</div>
                <div class="card-label">{HTML["COMMITS"]}</div>
            </div>
            <div class="card">
                <div class="card-icon">📊</div>
                <div class="card-value">{stats["commits_per_week"]}</div>
                <div class="card-label">{HTML["WEEKLY_COMMITS"]}</div>
            </div>
            <div class="card">
                <div class="card-icon">➕</div>
                <div class="card-value">{stats["lines_added"]:,}</div>
                <div class="card-label">{HTML["LINES_ADDED"]}</div>
            </div>'''

    html_content += f'''
            <div class="card">
                <div class="card-icon">➖</div>
                <div class="card-value">{stats["lines_deleted"]:,}</div>
                <div class="card-label">{HTML["LINES_DELETED"]}</div>
            </div>
            <div class="card">
                <div class="card-icon">⚡</div>
                <div class="card-value">{stats["daily_lines"]}</div>
                <div class="card-label">{HTML["DAILY_LINES"]}</div>
            </div>
            <div class="card">
                <div class="card-icon">📅</div>
                <div class="card-value">{stats["active_days"]}</div>
                <div class="card-label">{HTML["ACTIVE_DAYS"]}</div>
            </div>'''

    html_content += f'''
            <div class="card">
                <div class="card-icon">💼</div>
                <div class="card-value">{stats["workday_ratio"]}%</div>
                <div class="card-label">{HTML["WORKDAY_RATIO"]}</div>
            </div>
            <div class="card">
                <div class="card-icon">🚀</div>
                <div class="card-value">{stats["first_commit"]}</div>
                <div class="card-label">{HTML["FIRST_COMMIT"]}</div>
            </div>
            <div class="card">
                <div class="card-icon">🏁</div>
                <div class="card-value">{stats["last_commit"]}</div>
                <div class="card-label">{HTML["LAST_COMMIT"]}</div>
            </div>'''

    html_content += f'''
            <div class="card">
                <div class="card-icon">🌅</div>
                <div class="card-value">{stats["earliest_commit"]}</div>
                <div class="card-label">{HTML["EARLIEST_TIME"]}</div>
            </div>
            <div class="card">
                <div class="card-icon">🌙</div>
                <div class="card-value">{stats["latest_commit"]}</div>
                <div class="card-label">{HTML["LATEST_TIME"]}</div>
            </div>'''

    html_content += f'''
            <div class="card">
                <div class="card-icon">🐂</div>
                <div class="card-value">{stats["niu_index"]}</div>
                <div class="card-label">{HTML["NIU_INDEX"]}</div>
            </div>
            <div class="card">
                <div class="card-icon">🐴</div>
                <div class="card-value">{stats["ma_index"]}</div>
                <div class="card-label">{HTML["MA_INDEX"]}</div>
            </div>
        </div>'''

    html_content += f'''
        <div class="footer">
            <p>{HTML["GENERATED"]}: {timestamp}</p>
        </div>
    </div>
</body>
</html>'''

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(html_content)

    print_info(f"HTML report generated: {output_file}")


def main():
    """Main function"""
    show_welcome()

    # Get repo path
    if len(sys.argv) > 1:
        repo_path = os.path.abspath(sys.argv[1])
    else:
        repo_path = os.getcwd()

    # Validate
    validate_git_repo(repo_path)

    # Get user
    git_user = get_git_user(repo_path)

    # Collect stats
    stats = collect_stats(repo_path, git_user)

    # Generate HTML
    output_file = os.path.join(repo_path, f"git-annual-{CURRENT_YEAR}.html")
    generate_html(stats, output_file)

    # Open report
    print_info(MSG["OPENING"])
    webbrowser.open(f"file://{output_file}")

    print()
    print_info(MSG["DONE"])


if __name__ == "__main__":
    main()
