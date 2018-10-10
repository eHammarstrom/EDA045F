if [ "$1" == "" ]
then
  echo "Specify folder name."
  exit 1
fi

mvn -B archetype:generate \
    -DarchetypeGroupId=org.apache.maven.archetypes \
    -DgroupId=eda045f \
    -DartifactId=$1
