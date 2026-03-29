include .env

# make db-script t="mst_propinsi"
db-script:
	@goose -dir "./migrations" -s create "$t" sql

# make db-create name="mst_test"
db-create:
	@goose create "&name" sql

db-migrate:
# @export $(GOOSE_DRIVER)
# @export $(GOOSE_DBSTRING)
# export GOOSE_DRIVER="$(GOOSE_DRIVER)"
# echo $(GOOSE_DRIVER)	
# export GOOSE_DBSTRING=$(GOOSE_DBSTRING)
	export MYFUNC := $(GOOSE_DBSTRING="xxxx")
	$(info  MYFUNC: $(MYFUNC))
# @echo $(GOOSE_DBSTRING)
# @goose up -dir ./$(MIGRATION_DIR)

up:
	@docker compose up

backup-db:
	@echo "-> Running $@";
	./script_backup

restore-db:
	@echo "-> Running $@";
	./script_restore

#   ___ __ ____
#  / __|  |_  _)
# ( (_ \)(  )(
#  \___(__)(__)
git-push:
# make git m="testing make for git"
	@git add .
	@git commit -m "$m"
	@git push -u origin $(GIT_BRANCH_NAME)