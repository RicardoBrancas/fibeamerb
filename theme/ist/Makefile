LOGS=base.log dei.log
OUTPUT= \
	beamercolorthemefibeamer-ist.sty beamerfontthemefibeamer-ist.sty \
	beamerinnerthemefibeamer-ist.sty beamerouterthemefibeamer-ist.sty \
	beamercolorthemefibeamer-ist-dei.sty

.PHONY: explode implode clean all
all: explode
explode: $(LOGS)

%.log: %.ins %.dtx
	xetex $<

implode:
	rm -f $(OUTPUT) $(LOGS)
