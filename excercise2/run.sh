#!/bin/bash

rtJAR=/usr/lib/jvm/java-8-oracle/jre/lib/rt.jar
jceJAR=/usr/lib/jvm/java-8-oracle/jre/lib/jce.jar

if [[ "$rtJAR" -eq "" || "$jceJAR" -eq "" ]]
then
  echo "Path to rt.jar and jce.jar must be set."
  exit 1
fi

if [ ! -d ./examples ]
then
  mkdir examples
  cd examples

  wget http://fileadmin.cs.lth.se/cs/Education/EDA045F/2018/web/bcel-6.2.jar
  wget http://fileadmin.cs.lth.se/cs/Education/EDA045F/2018/web/bcel-6.2-src.tar.gz

  wget http://fileadmin.cs.lth.se/cs/Education/EDA045F/2018/web/xalan-2.7.2.jar
  wget http://fileadmin.cs.lth.se/cs/Education/EDA045F/2018/web/xalan-2.7.2-src.tar.gz

  wget http://fileadmin.cs.lth.se/cs/Education/EDA045F/2018/web/javacc-5.0.jar
  wget http://fileadmin.cs.lth.se/cs/Education/EDA045F/2018/web/javacc-5.0-src.tar.gz

  cd ..
fi

cpSOOT=\
target/classes\
:target/lib/junit-3.8.2.jar\
:$rtJAR:$jceJAR\
:examples/javacc-5.0.jar\
:examples/bcel-6.2.jar\
:examples/xalan-2.7.2.jar

mvn clean
mvn package

: '
for filename in ./examples/*; do
    if [[ -f $filename ]]; then
        echo "----------------------------------------------"
        echo "Running for: $filename"
        echo "----------------------"
        java -cp target/classes:target/lib/* eda045f.exercises.MyMainClass -cp $cpSOOT -f jimple -process-dir $filename
        echo "----------------------------------------------"
    fi
done
'

javacc_mains=jjdoc:jjtree:javacc:org.javacc.jjtree.Main:org.javacc.utils.JavaFileGenerator:org.javacc.jjdoc.JJDocMain:org.javacc.parser.Main

bcel_mains=org.apache.bcel.util.Class2HTML:org.apache.bcel.util.JavaWrapper:org.apache.bcel.util.BCELifier:org.apache.bcel.verifier.TransitiveHull:org.apache.bcel.verifier.Verifier:org.apache.bcel.verifier.NativeVerifier:org.apache.bcel.verifier.GraphicalVerifier:org.apache.bcel.verifier.VerifyDialog:org.apache.bcel.verifier.exc.AssertionViolatedException

xalan_mains=java_cup.Main:org.apache.xml.dtm.ref.IncrementalSAXSource_Xerces:org.apache.xml.dtm.ref.DTMSafeStringPool:org.apache.xml.dtm.ref.DTMStringPool:org.apache.xml.serializer.Version:org.apache.xml.resolver.apps.resolver:org.apache.xml.resolver.apps.xparse:org.apache.xml.resolver.apps.xread:org.apache.xml.resolver.Version:org.apache.xml.resolver.tests.BasicResolverTests:org.apache.xmlcommons.Version:org.apache.xerces.impl.xpath.regex.REUtil:org.apache.xerces.impl.xpath.XPath:org.apache.xerces.impl.Version:org.apache.xerces.impl.Constants:org.apache.xalan.xslt.EnvironmentCheck:org.apache.xalan.xslt.Process:org.apache.xalan.xsltc.util.JavaCupRedirect:org.apache.xalan.xsltc.cmdline.Compile:org.apache.xalan.xsltc.cmdline.Transform:org.apache.xalan.xsltc.ProcessorVersion:org.apache.xalan.lib.sql.ObjectArray:org.apache.xalan.processor.XSLProcessorVersion:org.apache.xalan.Version

if [ "$1" == "javacc" ]; then
  java -cp target/classes:target/lib/* excercise2.MyMainClass $cpSOOT $javacc_mains
elif [ "$1" == "bcel" ]; then
  java -cp target/classes:target/lib/* excercise2.MyMainClass $cpSOOT $bcel_mains
elif [ "$1" == "xalan" ]; then
  java -cp target/classes:target/lib/* excercise2.MyMainClass $cpSOOT $xalan_mains
else
  if [ "$1" != "" ]; then
    java -cp target/classes:target/lib/* excercise2.MyMainClass $cpSOOT $1
  else
    echo "Usage: ./run.sh [javacc, bcel, xalan, package.MyClass]"
  fi
fi

# java -cp target/DFAnalysis1-1.0-SNAPSHOT.jar:target/lib/* eda045f.exercises.MyMainClass -cp $cpSOOT -f j -p jb preserve-source-annotations eda045f.exercises.test.Foo
