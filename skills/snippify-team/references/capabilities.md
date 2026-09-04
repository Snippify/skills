# Team capability baseline

As of the current repository implementation:

| Capability | Status |
| --- | --- |
| Authenticated owned-Workspace listing | Available through `list_workspaces` |
| Owner-private Artifact retrieval and version listing | Available |
| Agent-created private version-1 draft | Available through `save_artifact` |
| Team membership model and authorization | Not implemented |
| Team-visible Artifact creation or visibility transition | Not implemented |
| Team review, invitation, or publication tools | Not implemented |

Therefore, the current tools cannot fulfill a team-sharing request. The connected server schema is authoritative if the deployment is newer than this repository. Require explicit team semantics in that schema before proceeding; a Workspace whose `kind` merely looks team-related is not sufficient evidence of member authorization or team visibility.
