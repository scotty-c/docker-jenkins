def project = 'Deploy container'
def jobName = 'Deploy container'
    job(jobName) {

        deliveryPipelineView("${project}") {
            pipelineInstances(1)
            showAggregatedPipeline()
            columns(1)
            sorting(Sorting.TITLE)
            updateInterval(60)
            enableManualTriggers()
            showAvatars()
            showChangeLog()
            pipelines {
                regex(/${project}-(.*)/)
            }
        }

        steps { 
            shell(readFileFromWorkspace('build.sh'))
        }
        
    }

