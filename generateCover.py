from __future__ import annotations

import argparse
import os
import shutil
from pathlib import Path
from typing import Optional

from openai import OpenAI


def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate LaTeX cover letters using OpenAI"
    )
    parser.add_argument("--covers-dir", required=True, type=Path)
    parser.add_argument("--cv-path", required=True, type=Path)
    parser.add_argument("--system-prompt-path", required=True, type=Path)
    parser.add_argument("--example-path", required=False, type=Path)
    parser.add_argument("--model", default="gpt-5.2")
    return parser.parse_args()


def create_openai_client() -> OpenAI:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise SystemExit('OPENAI_API_KEY is not set. Use: setx OPENAI_API_KEY "sk-..."')
    return OpenAI(api_key=api_key)


def validate_inputs(
    covers_dir: Path,
    cv_path: Path,
    prompt_path: Path,
    example_path: Optional[Path] = None,
) -> None:
    if not covers_dir.exists():
        raise SystemExit(f"Folder not found: {covers_dir}")
    if not cv_path.exists():
        raise SystemExit(f"CV file not found: {cv_path}")
    if not prompt_path.exists():
        raise SystemExit(f"System prompt file not found: {prompt_path}")


def generate_cover_letter(
    *,
    txt_path: Path,
    cv_text: str,
    system_prompt: str,
    example: Optional[str],
    model: str,
    client: OpenAI,
) -> None:
    out_tex_path = txt_path.with_suffix(".tex")

    job_text = read_text(txt_path)

    user_prompt = build_user_prompt(
        cv_text=cv_text,
        job_text=job_text,
        existing_tex_template=example,
    )

    response = client.responses.create(
        model=model,
        input=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        max_output_tokens=1200,
    )

    latex = (response.output_text or "").strip()
    error = validate_latex_output(latex)
    if error:
        raise SystemExit(
            f"Model output failed checks for {txt_path.name}: {error}\n"
            f"---\n{latex[:800]}\n---"
        )

    if out_tex_path.exists():
        shutil.copy2(out_tex_path, out_tex_path.with_suffix(".tex.bak"))

    out_tex_path.write_text(latex + "\n", encoding="utf-8")
    print(f"OK: {txt_path.name} -> {out_tex_path.name}")


def build_user_prompt(
    cv_text: str, job_text: str, existing_tex_template: Optional[str]
) -> str:
    parts = []
    parts.append("[CV]\n" + cv_text)
    parts.append("[JOB OFFER]\n" + job_text)
    if existing_tex_template:
        parts.append("[LATEX TEMPLATE TO RESPECT]\n" + existing_tex_template)
    return "\n\n".join(parts)


def validate_latex_output(tex: str) -> Optional[str]:
    if "\\begin{document}" not in tex or "\\end{document}" not in tex:
        return "Missing \\begin{document} or \\end{document}"
    if "```" in tex:
        return "Contains markdown fences"
    return None


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace").strip()


def main() -> None:
    args = parse_args()

    validate_inputs(
        args.covers_dir, args.cv_path, args.system_prompt_path, args.example_path
    )

    client = create_openai_client()
    system_prompt = read_text(args.system_prompt_path)
    cv_text = read_text(args.cv_path)
    model = args.model
    example = read_text(args.example_path) if args.example_path else None

    txt_files = sorted(args.covers_dir.glob("*.txt"))
    if not txt_files:
        raise SystemExit(f"No .txt files found in: {args.covers_dir}")

    for txt_path in txt_files:
        generate_cover_letter(
            txt_path=txt_path,
            cv_text=cv_text,
            system_prompt=system_prompt,
            example=example,
            model=model,
            client=client,
        )

    print("Done.")


if __name__ == "__main__":
    main()
