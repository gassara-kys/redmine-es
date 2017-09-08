FROM elasticsearch:5.5

# x-pack
RUN elasticsearch-plugin  install --batch x-pack

# kuromoji
RUN elasticsearch-plugin  install analysis-kuromoji
