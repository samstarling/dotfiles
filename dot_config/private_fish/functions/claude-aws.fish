function claude-aws --description "Claude Code via AWS Bedrock"
    env CLAUDE_CODE_USE_BEDROCK=1 \
        AWS_PROFILE=semaloop \
        AWS_REGION=eu-west-2 \
        claude $argv
end
