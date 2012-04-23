#---------------------------------------------------------------------
HOMEDIR         = __dirname + "/.."
IS_COFFEE       = process.argv[0].indexOf("coffee") >= 0
IS_INSTRUMENTED = (require('path')).existsSync(HOMEDIR+'/lib-cov')
LIB_DIR         = if IS_INSTRUMENTED then HOMEDIR+"/lib-cov" else HOMEDIR+"/lib"
FILE_SUFFIX     = if IS_COFFEE then ".coffee" else ".js"
PHONY           = LIB_DIR + "/phony"  + FILE_SUFFIX
#---------------------------------------------------------------------

argv = require('optimist')
  .default("count",1)
  .default("method","name")
  .default("return","string")
  .argv

phony = require(PHONY).make_phony()

method = phony[argv.method]
count = argv.count

for i in [0...count]
  console.log method({"return":argv.return})
