#!/bin/bash

# Git Annual Summary Generator
# Generate a beautiful HTML report showing your yearly Git contributions

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect system language
detect_language() {
    local lang="${LANG:-${LC_ALL:-en}}"
    if [[ "$lang" == zh_CN* ]] || [[ "$lang" == zh_TW* ]] || [[ "$lang" == zh_HK* ]]; then
        echo "zh"
    else
        echo "en"
    fi
}

# Current language
CURRENT_LANG=$(detect_language)

# Initialize i18n texts
init_i18n() {
    if [ "$CURRENT_LANG" = "zh" ]; then
        # Terminal messages - Chinese
        MSG_INFO="[信息]"
        MSG_ERROR="[错误]"
        MSG_WARNING="[警告]"
        MSG_WELCOME_TITLE="Git 年度总结生成器"
        MSG_PATH_NOT_EXIST="路径不存在"
        MSG_DIR_NOT_EXIST="目录不存在"
        MSG_NOT_GIT_REPO="不是 Git 仓库"
        MSG_FOUND_REPO="找到 Git 仓库"
        MSG_USER_NOT_FOUND="未找到 Git 用户配置，将统计所有提交"
        MSG_GIT_USER="Git 用户"
        MSG_COLLECTING="正在收集 %s 年的统计数据..."
        MSG_DATE_RANGE="日期范围: %s 至 %s"
        MSG_TOTAL_ALL_TIME="仓库总提交数（所有时间）"
        MSG_NO_COMMITS="仓库没有任何提交！"
        MSG_TOTAL_THIS_YEAR="%s 年总提交数（所有作者）"
        MSG_NO_COMMITS_YEAR="%s 年没有提交！请检查仓库是否有该年的提交。"
        MSG_FILTER_AUTHOR="按作者筛选: '%s'"
        MSG_NO_FILTER="未筛选作者，统计所有提交"
        MSG_AUTHORS_IN_REPO="%s 年仓库作者:"
        MSG_COMMITS_MATCHED="匹配的提交数（含作者筛选）"
        MSG_AUTHOR_NOT_FOUND="作者 '%s' 未在提交中找到！请检查名称是否完全匹配。"
        MSG_STATS_COLLECTED="统计数据收集完成！"
        MSG_GENERATING="正在生成 HTML 报告..."
        MSG_REPORT_GENERATED="HTML 报告已生成"
        MSG_TIP="提示: 先运行 'git fetch' 以确保统计数据完整"
        MSG_OPENING="正在打开报告..."
        MSG_DONE="完成！🎉"

        # HTML texts - Chinese
        HTML_TITLE="年度Git工作总结"
        HTML_HEADER="年度 Git 总结"
        HTML_THANKS="感谢"
        HTML_COMMITS="提交次数"
        HTML_WEEKLY_COMMITS="每周提交"
        HTML_LINES_ADDED="新增行数"
        HTML_LINES_DELETED="删除行数"
        HTML_DAILY_LINES="日均代码量"
        HTML_ACTIVE_DAYS="活跃天数"
        HTML_WORKDAY_RATIO="工作日占比"
        HTML_FIRST_COMMIT="首次提交"
        HTML_LAST_COMMIT="最后提交"
        HTML_EARLIEST_TIME="最早提交时间"
        HTML_LATEST_TIME="最晚提交时间"
        HTML_NIU_INDEX="牛指数（代码量）"
        HTML_MA_INDEX="马指数（提交频次）"
        HTML_GENERATED="生成时间"
        HTML_NONE="无"

        # Niu/Ma index - Chinese
        NIU_1="小牛（1/4）"
        NIU_2="壮牛（2/4）"
        NIU_3="猛牛（3/4）"
        NIU_4="神牛（4/4）"
        MA_1="小马（1/4）"
        MA_2="快马（2/4）"
        MA_3="烈马（3/4）"
        MA_4="神马（4/4）"

        # Summary comments - Chinese
        SUMMARY_GOD="神中神！你是如何做到的？生产队的驴看了都自愧不如 🏆"
        SUMMARY_CODE_MANIAC="代码狂魔！生产队的驴都没你能写 💪"
        SUMMARY_COMMIT_MANIAC="提交狂人！键盘都要被你敲冒烟了 🔥"
        SUMMARY_NIUMA="牛马本马！两眼一睁干到熄灯 🐂🐴"
        SUMMARY_STEADY="稳扎稳打，打工人的标准姿态 👔"
        SUMMARY_CHILL="佛系打工，只要心态好，公司就是巴厘岛 🏝️"
        SUMMARY_DEFAULT="条条大路当牛马，感谢努力的自己 ✨"
    else
        # Terminal messages - English
        MSG_INFO="[INFO]"
        MSG_ERROR="[ERROR]"
        MSG_WARNING="[WARNING]"
        MSG_WELCOME_TITLE="Git Annual Summary Generator"
        MSG_PATH_NOT_EXIST="Path does not exist"
        MSG_DIR_NOT_EXIST="Directory does not exist"
        MSG_NOT_GIT_REPO="Not a git repository"
        MSG_FOUND_REPO="Found git repository"
        MSG_USER_NOT_FOUND="Git user config not found, will count all commits"
        MSG_GIT_USER="Git user"
        MSG_COLLECTING="Collecting statistics for year %s..."
        MSG_DATE_RANGE="Date range: %s to %s"
        MSG_TOTAL_ALL_TIME="Total commits in repo (all time)"
        MSG_NO_COMMITS="Repository has no commits at all!"
        MSG_TOTAL_THIS_YEAR="Total commits in %s (all authors)"
        MSG_NO_COMMITS_YEAR="No commits found in %s! Check if repo has commits this year."
        MSG_FILTER_AUTHOR="Filtering by author: '%s'"
        MSG_NO_FILTER="No author filter, counting all commits"
        MSG_AUTHORS_IN_REPO="Authors in this repo (%s):"
        MSG_COMMITS_MATCHED="Commits matched (with author filter)"
        MSG_AUTHOR_NOT_FOUND="Author '%s' not found in commits! Check if name matches exactly."
        MSG_STATS_COLLECTED="Statistics collected!"
        MSG_GENERATING="Generating HTML report..."
        MSG_REPORT_GENERATED="HTML report generated"
        MSG_TIP="Tip: Run 'git fetch' first to ensure complete statistics"
        MSG_OPENING="Opening report..."
        MSG_DONE="Done! 🎉"

        # HTML texts - English
        HTML_TITLE="Git Annual Summary"
        HTML_HEADER="Git Annual Summary"
        HTML_THANKS="Thanks for"
        HTML_COMMITS="Commits"
        HTML_WEEKLY_COMMITS="Weekly Commits"
        HTML_LINES_ADDED="Lines Added"
        HTML_LINES_DELETED="Lines Deleted"
        HTML_DAILY_LINES="Daily Lines"
        HTML_ACTIVE_DAYS="Active Days"
        HTML_WORKDAY_RATIO="Workday Ratio"
        HTML_FIRST_COMMIT="First Commit"
        HTML_LAST_COMMIT="Last Commit"
        HTML_EARLIEST_TIME="Earliest Time"
        HTML_LATEST_TIME="Latest Time"
        HTML_NIU_INDEX="Niu Index (Code)"
        HTML_MA_INDEX="Ma Index (Commits)"
        HTML_GENERATED="Generated at"
        HTML_NONE="N/A"

        # Niu/Ma index - English
        NIU_1="Calf (1/4)"
        NIU_2="Bull (2/4)"
        NIU_3="Mighty (3/4)"
        NIU_4="Legend (4/4)"
        MA_1="Pony (1/4)"
        MA_2="Racer (2/4)"
        MA_3="Stallion (3/4)"
        MA_4="Legend (4/4)"

        # Summary comments - English
        SUMMARY_GOD="You're the GOAT! Built different, no cap 🏆"
        SUMMARY_CODE_MANIAC="10x Developer detected! Leetcode fears you 💪"
        SUMMARY_COMMIT_MANIAC="Git push speedrunner! Any% world record 🔥"
        SUMMARY_NIUMA="Sigma grindset activated! Rise and grind 🐂🐴"
        SUMMARY_STEADY="Solid 9-to-5 energy. Corporate wants you 👔"
        SUMMARY_CHILL="Quiet quitting? Nah, smart working 🏝️"
        SUMMARY_DEFAULT="Touched grass AND wrote code. Respect ✨"
    fi
}

# Year to summarize (fixed to 2025)
CURRENT_YEAR=2025

# Print colored messages
print_info() {
    echo -e "${GREEN}${MSG_INFO}${NC} $1"
}

print_error() {
    echo -e "${RED}${MSG_ERROR}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}${MSG_WARNING}${NC} $1"
}

# Show welcome message
show_welcome() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║     $MSG_WELCOME_TITLE     ║"
    echo "║                  V2                    ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
}

# Get repo path (from argument or use current directory)
get_repo_path() {
    local repo_path="$1"

    if [ -z "$repo_path" ]; then
        repo_path="."
    fi

    # Expand ~ symbol
    repo_path="${repo_path/#\~/$HOME}"

    # Convert to absolute path
    if [[ "$repo_path" != /* ]]; then
        repo_path="$(cd "$repo_path" 2>/dev/null && pwd)" || {
            print_error "$MSG_PATH_NOT_EXIST: $repo_path"
            exit 1
        }
    fi

    echo "$repo_path"
}

# Validate git repository
validate_git_repo() {
    local path="$1"

    if [ ! -d "$path" ]; then
        print_error "$MSG_DIR_NOT_EXIST: $path"
        exit 1
    fi

    if [ ! -d "$path/.git" ]; then
        print_error "$MSG_NOT_GIT_REPO: $path"
        exit 1
    fi

    print_info "$MSG_FOUND_REPO: $path"
}

# Get git user info
get_git_user() {
    local path="$1"
    cd "$path"

    # Check local config first, then global config
    local user_name=$(git config user.name 2>/dev/null || git config --global user.name 2>/dev/null || echo "")
    local user_email=$(git config user.email 2>/dev/null || git config --global user.email 2>/dev/null || echo "")

    if [ -z "$user_name" ] && [ -z "$user_email" ]; then
        print_warning "$MSG_USER_NOT_FOUND" >&2
        echo ""
    else
        print_info "$MSG_GIT_USER: $user_name <$user_email>" >&2
        echo "$user_name"
    fi
}

# Collect git statistics
collect_stats() {
    local path="$1"
    local author="$2"
    local year="$CURRENT_YEAR"

    cd "$path"

    local start_date="${year}-01-01"
    local end_date="${year}-12-31"

    # Build author argument (quoted for names with spaces)
    local author_arg=""
    if [ -n "$author" ]; then
        author_arg="--author=\"$author\""
    fi

    print_info "$(printf "$MSG_COLLECTING" "$year")"
    print_info "$(printf "$MSG_DATE_RANGE" "$start_date" "$end_date")"

    # Check total commits in repo (all time)
    local total_all_time=$(git log --oneline 2>/dev/null | wc -l | tr -d ' ')
    print_info "$MSG_TOTAL_ALL_TIME: $total_all_time"
    if [ "$total_all_time" -eq 0 ]; then
        print_warning "$MSG_NO_COMMITS"
    fi

    # Check commits in this year (no author filter)
    local total_this_year=$(git log --since="$start_date" --until="$end_date" --oneline 2>/dev/null | wc -l | tr -d ' ')
    print_info "$(printf "$MSG_TOTAL_THIS_YEAR" "$year"): $total_this_year"
    if [ "$total_this_year" -eq 0 ]; then
        print_warning "$(printf "$MSG_NO_COMMITS_YEAR" "$year")"
    fi

    # Show author filter info
    if [ -n "$author" ]; then
        print_info "$(printf "$MSG_FILTER_AUTHOR" "$author")"
    else
        print_info "$MSG_NO_FILTER"
    fi

    # Show all authors in this repo for debugging
    if [ "$total_this_year" -gt 0 ]; then
        print_info "$(printf "$MSG_AUTHORS_IN_REPO" "$year")"
        git log --since="$start_date" --until="$end_date" --format="%an" 2>/dev/null | sort | uniq -c | sort -rn | head -5 | while read line; do
            echo "         $line"
        done
    fi

    # Commit count
    COMMIT_COUNT=$(eval git log $author_arg --since=\"$start_date\" --until=\"$end_date\" --oneline 2>/dev/null | wc -l | tr -d ' ')
    print_info "$MSG_COMMITS_MATCHED: $COMMIT_COUNT"
    if [ -n "$author" ] && [ "$total_this_year" -gt 0 ] && [ "$COMMIT_COUNT" -eq 0 ]; then
        print_warning "$(printf "$MSG_AUTHOR_NOT_FOUND" "$author")"
    fi

    # Commits per week
    COMMITS_PER_WEEK=$(echo "scale=1; $COMMIT_COUNT / 52" | bc | sed 's/^\./0./')

    # Lines added and deleted
    local stats=$(eval git log $author_arg --since=\"$start_date\" --until=\"$end_date\" --numstat --pretty=format:\"\" 2>/dev/null | awk 'NF==3 {add+=$1; del+=$2} END {print add, del}')
    LINES_ADDED=$(echo "$stats" | awk '{print $1}')
    LINES_DELETED=$(echo "$stats" | awk '{print $2}')

    # Handle empty values
    [ -z "$LINES_ADDED" ] && LINES_ADDED=0
    [ -z "$LINES_DELETED" ] && LINES_DELETED=0

    # Active days
    ACTIVE_DAYS=$(eval git log $author_arg --since=\"$start_date\" --until=\"$end_date\" --format=\"%ad\" --date=short 2>/dev/null | sort -u | wc -l | tr -d ' ')

    # Workday activity ratio (248 workdays in 2025 China)
    WORKDAY_RATIO=$(echo "scale=1; $ACTIVE_DAYS * 100 / 248" | bc | sed 's/^\./0./')

    # Daily lines = (added + deleted) / workdays (248)
    DAILY_LINES=$(echo "scale=0; ($LINES_ADDED + $LINES_DELETED) / 248" | bc)

    # Niu index (based on daily code lines, 248 workdays)
    if [ "$DAILY_LINES" -lt 50 ]; then
        NIU_INDEX="$NIU_1"
        NIU_LEVEL=1
    elif [ "$DAILY_LINES" -lt 150 ]; then
        NIU_INDEX="$NIU_2"
        NIU_LEVEL=2
    elif [ "$DAILY_LINES" -lt 300 ]; then
        NIU_INDEX="$NIU_3"
        NIU_LEVEL=3
    else
        NIU_INDEX="$NIU_4"
        NIU_LEVEL=4
    fi

    # Ma index (based on weekly commits, 52 weeks)
    COMMITS_PER_WEEK_INT=$(echo "$COMMITS_PER_WEEK" | cut -d. -f1)
    [ -z "$COMMITS_PER_WEEK_INT" ] && COMMITS_PER_WEEK_INT=0
    if [ "$COMMITS_PER_WEEK_INT" -lt 3 ]; then
        MA_INDEX="$MA_1"
        MA_LEVEL=1
    elif [ "$COMMITS_PER_WEEK_INT" -lt 6 ]; then
        MA_INDEX="$MA_2"
        MA_LEVEL=2
    elif [ "$COMMITS_PER_WEEK_INT" -lt 15 ]; then
        MA_INDEX="$MA_3"
        MA_LEVEL=3
    else
        MA_INDEX="$MA_4"
        MA_LEVEL=4
    fi

    # Generate summary comment
    if [ "$NIU_LEVEL" -eq 4 ] && [ "$MA_LEVEL" -eq 4 ]; then
        SUMMARY="$SUMMARY_GOD"
    elif [ "$NIU_LEVEL" -eq 4 ]; then
        SUMMARY="$SUMMARY_CODE_MANIAC"
    elif [ "$MA_LEVEL" -eq 4 ]; then
        SUMMARY="$SUMMARY_COMMIT_MANIAC"
    elif [ "$NIU_LEVEL" -ge 3 ] && [ "$MA_LEVEL" -ge 3 ]; then
        SUMMARY="$SUMMARY_NIUMA"
    elif [ "$NIU_LEVEL" -ge 2 ] && [ "$MA_LEVEL" -ge 2 ]; then
        SUMMARY="$SUMMARY_STEADY"
    elif [ "$NIU_LEVEL" -le 1 ] && [ "$MA_LEVEL" -le 1 ]; then
        SUMMARY="$SUMMARY_CHILL"
    else
        SUMMARY="$SUMMARY_DEFAULT"
    fi

    # First commit date
    FIRST_COMMIT=$(eval git log $author_arg --since=\"$start_date\" --until=\"$end_date\" --format=\"%ad\" --date=short --reverse 2>/dev/null | head -1)
    [ -z "$FIRST_COMMIT" ] && FIRST_COMMIT="$HTML_NONE"

    # Last commit date
    LAST_COMMIT=$(eval git log $author_arg --since=\"$start_date\" --until=\"$end_date\" --format=\"%ad\" --date=short 2>/dev/null | head -1)
    [ -z "$LAST_COMMIT" ] && LAST_COMMIT="$HTML_NONE"

    # Earliest/Latest commit time (6am as day boundary)
    # Day starts at 6:00, ends at next day 5:59
    # Earliest = closest to 6:00, Latest = closest to 5:59
    local all_times=$(eval git log $author_arg --since=\"$start_date\" --until=\"$end_date\" --format=\"%ad\" --date=format:\"%H:%M\" 2>/dev/null)

    if [ -n "$all_times" ]; then
        # Convert to minutes from 6:00: 6:00=0, 7:00=60, ..., 23:59=1079, 00:00=1080, ..., 05:59=1439
        # Earliest = min minutes, Latest = max minutes
        EARLIEST_COMMIT=$(echo "$all_times" | awk -F: '{
            h=$1+0; m=$2+0;
            if(h>=6) mins=(h-6)*60+m;
            else mins=(h+18)*60+m;
            printf "%04d %s\n", mins, $0
        }' | sort -n | head -1 | awk '{print $2}')

        LATEST_COMMIT=$(echo "$all_times" | awk -F: '{
            h=$1+0; m=$2+0;
            if(h>=6) mins=(h-6)*60+m;
            else mins=(h+18)*60+m;
            printf "%04d %s\n", mins, $0
        }' | sort -rn | head -1 | awk '{print $2}')
    else
        EARLIEST_COMMIT="$HTML_NONE"
        LATEST_COMMIT="$HTML_NONE"
    fi

    # Repository name
    REPO_NAME=$(basename "$path")

    print_info "$MSG_STATS_COLLECTED"
}

# Format number (add thousand separator, macOS compatible)
format_number() {
    printf "%'d" "$1" 2>/dev/null || echo "$1"
}

# Generate HTML report
generate_html() {
    local output_file="$1"
    local year="$CURRENT_YEAR"

    print_info "$MSG_GENERATING"

    # Determine HTML lang attribute
    local html_lang="en"
    [ "$CURRENT_LANG" = "zh" ] && html_lang="zh-CN"

    cat > "$output_file" << EOF
<!DOCTYPE html>
<html lang="$html_lang">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$HTML_TITLE</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
        }

        .header {
            text-align: center;
            color: white;
            margin-bottom: 40px;
        }

        .header h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        }

        .header .subtitle {
            font-size: 1.2rem;
            opacity: 0.9;
        }

        .cards {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .card {
            background: white;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            transition: transform 0.3s ease;
        }

        .card:hover {
            transform: translateY(-5px);
        }

        .card-icon {
            font-size: 2.5rem;
            margin-bottom: 12px;
        }

        .card-value {
            font-size: 2.2rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 8px;
        }

        .card-label {
            font-size: 0.95rem;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .footer {
            text-align: center;
            color: white;
            opacity: 0.8;
            font-size: 0.9rem;
            margin-top: 20px;
        }

        .highlight {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }

        .highlight .card-value,
        .highlight .card-label {
            color: white;
        }

        .summary {
            text-align: center;
            margin: 40px 0;
            padding: 30px;
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
        }

        .summary-title {
            font-size: 2.5rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 15px;
        }

        .summary-text {
            font-size: 1.3rem;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
EOF

    # Write header section
    cat >> "$output_file" << EOF
        <div class="header">
            <h1>🎉 ${year} $HTML_HEADER</h1>
            <div class="subtitle">📁 ${REPO_NAME}</div>
        </div>

        <div class="summary">
            <div class="summary-title">$HTML_THANKS ${year} 🎊</div>
            <div class="summary-text">${SUMMARY}</div>
        </div>

        <div class="cards">
            <div class="card highlight">
                <div class="card-icon">📝</div>
                <div class="card-value">$(format_number $COMMIT_COUNT)</div>
                <div class="card-label">$HTML_COMMITS</div>
            </div>

            <div class="card">
                <div class="card-icon">📊</div>
                <div class="card-value">${COMMITS_PER_WEEK}</div>
                <div class="card-label">$HTML_WEEKLY_COMMITS</div>
            </div>

            <div class="card">
                <div class="card-icon">➕</div>
                <div class="card-value">$(format_number $LINES_ADDED)</div>
                <div class="card-label">$HTML_LINES_ADDED</div>
            </div>

            <div class="card">
                <div class="card-icon">➖</div>
                <div class="card-value">$(format_number $LINES_DELETED)</div>
                <div class="card-label">$HTML_LINES_DELETED</div>
            </div>

            <div class="card">
                <div class="card-icon">⚡</div>
                <div class="card-value">${DAILY_LINES}</div>
                <div class="card-label">$HTML_DAILY_LINES</div>
            </div>

            <div class="card">
                <div class="card-icon">📅</div>
                <div class="card-value">${ACTIVE_DAYS}</div>
                <div class="card-label">$HTML_ACTIVE_DAYS</div>
            </div>

            <div class="card">
                <div class="card-icon">💼</div>
                <div class="card-value">${WORKDAY_RATIO}%</div>
                <div class="card-label">$HTML_WORKDAY_RATIO</div>
            </div>

            <div class="card">
                <div class="card-icon">🚀</div>
                <div class="card-value">${FIRST_COMMIT}</div>
                <div class="card-label">$HTML_FIRST_COMMIT</div>
            </div>

            <div class="card">
                <div class="card-icon">🏁</div>
                <div class="card-value">${LAST_COMMIT}</div>
                <div class="card-label">$HTML_LAST_COMMIT</div>
            </div>

            <div class="card">
                <div class="card-icon">🌅</div>
                <div class="card-value">${EARLIEST_COMMIT}</div>
                <div class="card-label">$HTML_EARLIEST_TIME</div>
            </div>

            <div class="card">
                <div class="card-icon">🌙</div>
                <div class="card-value">${LATEST_COMMIT}</div>
                <div class="card-label">$HTML_LATEST_TIME</div>
            </div>

            <div class="card">
                <div class="card-icon">🐂</div>
                <div class="card-value">${NIU_INDEX}</div>
                <div class="card-label">$HTML_NIU_INDEX</div>
            </div>

            <div class="card">
                <div class="card-icon">🐴</div>
                <div class="card-value">${MA_INDEX}</div>
                <div class="card-label">$HTML_MA_INDEX</div>
            </div>
        </div>

        <div class="footer">
            <p>$HTML_GENERATED: $(date '+%Y-%m-%d %H:%M:%S')</p>
        </div>
    </div>
</body>
</html>
EOF

    print_info "$MSG_REPORT_GENERATED: $output_file"
}

# Main function
main() {
    local input_path="$1"

    # Initialize i18n
    init_i18n

    show_welcome

    # Get repo path
    REPO_PATH=$(get_repo_path "$input_path")

    # Validate repository
    validate_git_repo "$REPO_PATH"

    # Tip for data completeness
    print_info "$MSG_TIP"
    echo ""

    # Get user info
    GIT_USER=$(get_git_user "$REPO_PATH")

    # Collect statistics
    collect_stats "$REPO_PATH" "$GIT_USER"

    # Generate HTML
    OUTPUT_FILE="${REPO_PATH}/git-annual-${CURRENT_YEAR}.html"
    generate_html "$OUTPUT_FILE"

    # Open HTML
    print_info "$MSG_OPENING"
    open "$OUTPUT_FILE"

    echo ""
    print_info "$MSG_DONE"
}

# Run main function with first argument
main "$1"
