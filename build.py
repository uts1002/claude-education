#!/usr/bin/env python3
"""
AI Fluency 학습 허브 빌더
========================

사용법:
    python build.py

동작:
    1. courses/_meta.json 읽음
    2. courses/{코스}/*.md, *.quiz.json 스캔
    3. 모든 콘텐츠를 단일 JSON으로 모음
    4. site/index.html의 <script id="course-data"> 안에 임베드

새 강의 추가 방법:
    1. courses/{코스 폴더}/NN-제목.md 작성
    2. courses/{코스 폴더}/NN-제목.quiz.json 작성
    3. courses/{코스}/_course.json의 lessons 배열에 추가
    4. python build.py 실행
    → site/index.html이 자동으로 갱신됩니다.

번거롭게 직접 빌드하기 싫으면 — Claude에게 "새 강의 추가해줘"라고만 해도
같은 결과를 만들어줍니다.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
COURSES_DIR = ROOT / "courses"
SITE_DIR = ROOT / "site"
INDEX_HTML = SITE_DIR / "index.html"
PLACEHOLDER_START = "/* COURSE_DATA_START */"
PLACEHOLDER_END = "/* COURSE_DATA_END */"


def parse_frontmatter(text: str) -> tuple[dict, str]:
    """간단한 YAML 프론트매터 파서 — 우리 콘텐츠에 필요한 만큼만."""
    fm: dict = {}
    body = text
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    if not m:
        return fm, body
    body = text[m.end():]
    for line in m.group(1).splitlines():
        line = line.rstrip()
        if not line or line.startswith("#"):
            continue
        k, _, v = line.partition(":")
        k = k.strip()
        v = v.strip()
        # 배열: [a, b, c]
        if v.startswith("[") and v.endswith("]"):
            inner = v[1:-1].strip()
            if not inner:
                fm[k] = []
            else:
                fm[k] = [
                    item.strip().strip('"').strip("'")
                    for item in inner.split(",")
                ]
        # 따옴표 문자열
        elif (v.startswith('"') and v.endswith('"')) or (
            v.startswith("'") and v.endswith("'")
        ):
            fm[k] = v[1:-1]
        # 숫자
        elif re.match(r"^-?\d+(\.\d+)?$", v):
            fm[k] = float(v) if "." in v else int(v)
        else:
            fm[k] = v
    return fm, body


def collect_lesson(course_id: str, lesson_id: str) -> dict | None:
    md_path = COURSES_DIR / course_id / f"{lesson_id}.md"
    quiz_path = COURSES_DIR / course_id / f"{lesson_id}.quiz.json"
    if not md_path.exists():
        print(f"  ⚠ 강의 파일 없음: {md_path.relative_to(ROOT)}", file=sys.stderr)
        return None
    text = md_path.read_text(encoding="utf-8")
    frontmatter, body = parse_frontmatter(text)
    quiz = None
    if quiz_path.exists():
        try:
            quiz = json.loads(quiz_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            print(f"  ⚠ 퀴즈 JSON 파싱 실패 {quiz_path.name}: {e}", file=sys.stderr)
    return {
        "id": lesson_id,
        "courseId": course_id,
        "path": f"{course_id}/{lesson_id}",
        "frontmatter": frontmatter,
        "body": body,
        "quiz": quiz,
    }


def build() -> dict:
    meta_path = COURSES_DIR / "_meta.json"
    if not meta_path.exists():
        print(f"❌ 메타 파일이 없습니다: {meta_path}", file=sys.stderr)
        sys.exit(1)
    meta = json.loads(meta_path.read_text(encoding="utf-8"))
    data: dict = {"meta": meta, "courses": [], "lessons": []}
    for course_summary in meta.get("courses", []):
        course_id = course_summary["id"]
        course_json = COURSES_DIR / course_id / "_course.json"
        if not course_json.exists():
            print(f"  ⚠ 코스 설정 없음: {course_json.relative_to(ROOT)}", file=sys.stderr)
            continue
        course_def = json.loads(course_json.read_text(encoding="utf-8"))
        data["courses"].append({**course_summary, **course_def})
        for lesson_id in course_def.get("lessons", []):
            lesson = collect_lesson(course_id, lesson_id)
            if lesson:
                data["lessons"].append(lesson)
    return data


def inject(data: dict) -> None:
    if not INDEX_HTML.exists():
        print(f"❌ site/index.html 없음. 먼저 site/index.html을 만들어주세요.", file=sys.stderr)
        sys.exit(1)
    html = INDEX_HTML.read_text(encoding="utf-8")
    start = html.find(PLACEHOLDER_START)
    end = html.find(PLACEHOLDER_END)
    if start == -1 or end == -1 or end < start:
        print(
            "❌ site/index.html에 COURSE_DATA 플레이스홀더가 없습니다. "
            "<script>{PLACEHOLDER_START} ... {PLACEHOLDER_END}</script> 구간을 추가해주세요.",
            file=sys.stderr,
        )
        sys.exit(1)
    inner = "\nwindow.__COURSE_DATA__ = " + json.dumps(data, ensure_ascii=False, indent=2) + ";\n"
    new_html = (
        html[: start + len(PLACEHOLDER_START)] + inner + html[end:]
    )
    INDEX_HTML.write_text(new_html, encoding="utf-8")
    print(f"✓ {INDEX_HTML.relative_to(ROOT)} 갱신 완료")


def main() -> None:
    print("AI Fluency 학습 허브 빌드 시작…")
    data = build()
    print(f"  • 코스 {len(data['courses'])}개")
    print(f"  • 강의 {len(data['lessons'])}편")
    inject(data)
    print("완료! site/index.html을 더블클릭해서 학습을 시작하세요.")


if __name__ == "__main__":
    main()
