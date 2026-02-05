import type { AnyAgentTool } from "./common.js";
import { logWarn } from "../../logger.js";
import { Type } from "@sinclair/typebox";

/**
 * Exec tool - execute shell commands with approval workflow
 *
 * This is a minimal implementation to fix build errors.
 * TODO: Implement full exec tool functionality with proper error handling,
 * timeout support, and security validations.
 */

export const execToolName = "exec";

const ExecToolSchema = Type.Object({
  command: Type.String({ description: "Command to execute" }),
  args: Type.Optional(Type.Array(Type.String({ description: "Command arguments" }))),
  cwd: Type.Optional(Type.String({ description: "Working directory" })),
  timeoutSec: Type.Optional(Type.Number({ description: "Timeout in seconds" })),
});

export function createExecTool(): AnyAgentTool {
  return {
    label: "Exec",
    name: execToolName,
    description: "Execute shell commands (minimal implementation)",
    parameters: ExecToolSchema,
    execute: async (_toolCallId, args, _signal) => {
      const params = args as Record<string, unknown>;
      logWarn("Exec tool: minimal implementation - full functionality not yet available");

      const command = params.command as string | undefined;
      if (!command) {
        return {
          content: [
            {
              type: "text",
              text: "Error: command parameter is required",
            },
          ],
          details: { error: "command parameter is required" },
        };
      }

      // Minimal implementation - just return command info
      return {
        content: [
          {
            type: "text",
            text: `Exec tool called with command: ${command}`,
          },
        ],
        details: { command, args: params.args, cwd: params.cwd, timeoutSec: params.timeoutSec },
      };
    },
  };
}
