//!groovy

// Vars that may be useful in entire script

// Pipeline does not use the groovy `def var = ~/<pattern>/` to define
// java.util.regex.Pattern classes.  But it looks like it will take strings,
// but need to excape all '\'.
def urlRegEx = '^(?>https?+:\\/\\/|git@)[a-zA-Z0-9-_.]+(?::\\d+)?+\\/[a-zA-Z0-9-_.]+(?:\\/[a-zA-Z0-9-_.]+)*.git$'
def branchRegEx = '^[a-zA-Z-_.\\/]+$'

// Variables to define the run parameters are defined in each node{} section

// Useful functions (closures)

// Closure isEmptyString
//
// Check if a string is empty: string =~ /^&/ == true.
// If string is empty, return true, else return false
def isEmptyString(String myString) {
  myString =~ /^$/
}

// Closure doGitMerge
//
// Enter the git directory defined by gitDir, and perform a merge from
// sourceUrl:sourceBranch into targetBranch
//
// Returns true if a merge was performed, or false if no merge
// performed Return value does not indicate if an error was
// encountered, that will be set in the currentBuild.result variable.
def doGitMerge(String gitDir, String sourceUrl, String sourceBranch, String targetBranch) {
  // Default return value
  // Indicates if a merge was done
  def myReturn = false

  // Check to see if all URL, source/target branch variables are set
  if ( !isEmptyString(sourceUrl) && !isEmptyString(sourceBranch) && !isEmptyString(targetBranch) ) {
    // We will attempt to do something, but only if sourceUrl,
    // sourceBranch and targetBranch are sane (no ; or | as they will
    // be parsed by a shell).
    if ( sourceUrl =~ urlRegEx && sourceBranch =~ branchRegEx && targetBranch =~ branchRegEx ) {
      // Attempt the merge
      println "Merging Repo:'$sourceUrl' branch:'$sourceBranch' into branch '$targetBranch'"
      try {
        dir(gitDir) {
          // Bring in remote
          sh "git checkout -b merge.${sourceBranch} ${targetBranch}"
          sh "git pull ${sourceUrl} ${sourceBranch}"
          sh "git checkout ${targetBranch}"
          sh "git merge --no-ff merge.${sourceBranch}"
          myReturn = true
        }
      } catch(err) {
        println "ERROR merging Repo:'$sourceUrl' branch:'$sourceBranch' into branch '$targetBranch'"
        currentBuild.result = 'FAILURE'
      }
    } else {
      println "ERROR: Unable to perform merge as one of more of the strings do not match what was expected"
      print   "ERROR: sourceUrl: ${sourceUrl} is a URL: "
      println sourceUrl ==~ urlRegEx
      print   "ERROR: sourceBranch: ${sourceBranch} is a branch: "
      println sourceBranch ==~ branchRegEx
      print   "ERROR: targetBranch: ${targetBranch} is a branch: "
      println targetBranch ==~ targetBranch
      currentBuild.result = 'FAILURE'
    }
  }
  return myReturn
}

node ('gaea'){
  // Variables that define the run parameters for gaea
  def moabAccount = "gfdl_f"
  def nodeSize = 20
  def walltime = "01:00:00"
  def partition = "c3"

  //////////////////////////////////////////////////////////////////////
  stage 'Prepare workspace'
  // Clean workspace
  deleteDir()
  // Get MOM6 workspace, that includes the makefile
  git url: 'https://gitlab.gfdl.noaa.gov/alistair.adcroft/mom6-workspace.git', branch: 'master'

  //////////////////////////////////////////////////////////////////////
  stage 'Checkout source'
  sh 'make GITHUB="https://github.com/" clone'

  //////////////////////////////////////////////////////////////////////
  stage 'Perform merge'
  // Trying this to see if it keeps the merge stage from running through the
  // remainder of the build
  sh 'echo Performing merges, if requested'

  // MOM6-examples
  doGitMerge('MOM6-examples', MOM6E_srcURL, MOM6E_srcBranch, MOM6E_targetBranch)
  // MOM6
  doGitMerge('MOM6-examples/src/MOM6', MOM6_srcURL, MOM6_srcBranch, MOM6_targetBranch)
  // SIS2
  doGitMerge('MOM6-examples/src/SIS2', SIS2_srcURL, SIS2_srcBranch, SIS2_targetBranch)
  // icebergs
  doGitMerge('MOM6-examples/src/icebergs', ICB_srcURL, ICB_srcBranch, ICB_targetBranch)
  // FMS
  doGitMerge('MOM6-examples/src/FMS', FMS_srcURL, FMS_srcBranch, FMS_targetBranch)
  // coupler
  doGitMerge('MOM6-examples/src/coupler', CPL_srcURL, CPL_srcBranch, CPL_targetBranch)

  // After all merge attempts, exit with FAILURE if currentBuild.result =~ 'FAILURE'
  if ( currentBuild.result =~ 'FAILURE' ) {
    error "A merge failed, stopping pipeline"
  }

  //////////////////////////////////////////////////////////////////////
  stage 'build gnu'
  sh 'make gnu -j'
  //sh "pwd && ls -l"
  //stage 'Stage 2'
  //echo 'Hello World 2'
  //sh "pwd && ls -l"

  //////////////////////////////////////////////////////////////////////
  stage 'Prepare to run'
  sh 'make stats.all.md5sums'

//  //////////////////////////////////////////////////////////////////////
//  stage 'Launch and wait'
//  // The script to run on the batch node
//  def simpleScript = """cd \$PBS_O_WORKDIR
//pwd
//ls -l
//make gnu -j"""
//   sh "echo '$simpleScript' | MSUBQUERYINTERVAL=300 msub -K -A $moabAccount -N MOM6_jenkins_test -l partition=$partition,walltime=$walltime,nodes=$nodeSize"

  //////////////////////////////////////////////////////////////////////
  stage 'verify run'
  sh 'make test.all.md5sums'
}
