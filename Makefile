# -*- mode: Makefile; fill-column: 80; comment-column: 75; -*-

ERL = $(shell which erl)

ERLFLAGS= -pa $(CURDIR)/.eunit -pa $(CURDIR)/ebin -pa $(CURDIR)/*/ebin

REBAR=./rebar

PROJ_PLT=$(CURDIR)/.depsolver_plt

.PHONY: dialyzer typer clean distclean

compile:
	@./rebar get-deps compile
run:
	erl +K true +A30 -sname epubnub -config config/sys.config -pa ebin deps/*/ebin -eval '[application:start(A) || A <- [kernel, asn1, crypto, public_key, ranch, inets, sync] ]'
$(PROJ_PLT):
	dialyzer --output_plt $(PROJ_PLT) --build_plt \
		--apps erts kernel stdlib crypto public_key -r deps --fullpath

dialyzer: $(PROJ_PLT)
	dialyzer --plt $(PROJ_PLT) -pa deps/* --src src

typer: $(PROJ_PLT)
	typer --plt $(PROJ_PLT) -r ./src

clean:
	$(REBAR) clean

distclean: clean
	rm $(PROJ_PLT)
	rm -rvf $(CURDIR)/deps/*

