TEMPLATE=user/dac_template.jd
INPUT_FORMAT=markdown_github-hard_line_breaks+yaml_metadata_block
OUTPUT_FORMAT=html5

SRCS := $(wildcard user/*.md)
INTERMEDIATES := $(patsubst user/%.md,.build/%.md,$(SRCS))
OUTPUTS := $(patsubst user/%.md,html/user/%.jd,$(SRCS))

$(info SRCS=$(SRCS))
$(info INTERMEDIATES=$(INTERMEDIATES))
$(info OUTPUTS=$(OUTPUTS))

.SECONDARY: $(INTERMEDIATES)

all: $(OUTPUTS) Makefile

clean:
	rm -rf html
	rm -rf .build

.build/%.md: user/%.md .build Makefile
	echo "---" > $@
	echo "title: '$(shell head -n1 $<)'" >> $@
	echo "..." >> $@
	tail -n +3 $< >> $@

html/user/%.jd: .build/%.md $(TEMPLATE) html/user .build Makefile
	pandoc --template $(TEMPLATE) --from $(INPUT_FORMAT) --to $(OUTPUT_FORMAT) \
		--toc --toc-depth=2 $< --output $@ --standalone

html/user: Makefile
	mkdir -p html/user

.build: Makefile
	mkdir -p .build
