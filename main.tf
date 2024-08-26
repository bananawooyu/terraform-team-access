terraform { 
  cloud { 
    organization =  "KAL-test"

    workspaces { 
      name = "permission-test" 
    } 
  } 
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  my-org-name = "KAL-test"
}

resource "tfe_team" "dev" {                 #Team 생성
  name         = "dev"
  organization = local.my-org-name
}

resource "tfe_project" "test" {             #Project 생성
  name         = "korean-air-cppo-3"
  organization = local.my-org-name
}

resource "tfe_workspace" "test" {           #Workspace 생성
  name         = "my-code-workspace"
  organization = local.my-org-name
  project_id = tfe_project.test.id
  tag_names    = ["test", "app"]
}

resource "tfe_team_access" "test" {         #Workspace에 대한 Team Access 설정
  access       = "write"
  team_id      = tfe_team.dev.id
  workspace_id = tfe_workspace.test.id
}

resource "tfe_team_project_access" "admin" {    #Project에 대한 Team Access 설정
  access       = "custom"                       #[Read, Write, Maintin, Admin, Custom] 중 선택
  team_id      = tfe_team.dev.id
  project_id   = tfe_project.test.id

  project_access {
    settings = "read"                           #[read, update, delete] 중 선택
    teams    = "none"                           #[none, read, manage] 중 선택
  }
  workspace_access {                            #UI상 순서로 작성
    create         = true                       #Manage workspace
    move           = false
    delete         = false

    runs           = "apply"                    #[read, plan, apply] 중 선택
    variables      = "read"                    #[none, read, write] 중 선택
    state_versions = "write"                    #[none, read-outputs, read, write] 중 선택
    
    sentinel_mocks = "none"                     #[none, read] 중 선택 (Download Sentinel mocks)
    run_tasks      = false                      #[true, false] 중 선택 (Manage workspace Run Tasks)
    locking        = true                       #[true, false] 중 선택 (Lock/unlock workspaces)
  }
}
