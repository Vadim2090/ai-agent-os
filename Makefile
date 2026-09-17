.PHONY: test eval eval-skills eval-all
test:            ## Tier 0: static checks + hook unit tests (seconds, free)
	@bash tests/run.sh
eval: test       ## Tier 0 + Tier 1: behavioural golden prompts through claude -p (~$1)
	@python3 evals/headless/run.py
eval-skills:     ## Tier 2: skill evals with a no-plugin baseline (claude plugin eval)
	@claude plugin eval . --json evals/results/skills.json --threshold 0.8 --trust-plugin --scaffold --allow-tools Bash,Write,Edit --model $${EVAL_MODEL:-claude-sonnet-5} --max-cost-usd 10
eval-all:        ## Everything, then write evals/LAST_RUN.md (what the weekly routine runs)
	@bash evals/run-all.sh
