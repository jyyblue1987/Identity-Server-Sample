<?php
class SqlSvrReportType extends ReportTypeBase {
public static function init(&$report) {
    $environments = PhpReports::$config['environments'];

    if(!isset($environments[$report->options['Environment']][$report->options['Database']])) {
        throw new Exception("No ".$report->options['Database']." info defined for environment '".$report->options['Environment']."'");
    }

    //make sure the syntax highlighting is using the proper class
    SqlFormatter::$pre_attributes = "class='prettyprint linenums lang-sql'";

    $sqlsrv = $environments[$report->options['Environment']][$report->options['Database']];

    //default host macro to sqlsrv's host if it isn't defined elsewhere
    if(!isset($report->macros['host'])) $report->macros['host'] = $sqlsrv['host'];

    //replace legacy shorthand macro format
    foreach($report->macros as $key=>$value) {
        $params = $report->options['Variables'][$key];

        //macros shortcuts for arrays
        if(isset($params['multiple']) && $params['multiple']) {
            //allow {macro} instead of {% for item in macro %}{% if not item.first %},{% endif %}{{ item.value }}{% endfor %}
            //this is shorthand for comma separated list
            $report->raw_query = preg_replace('/([^\{])\{'.$key.'\}([^\}])/','$1{% for item in '.$key.' %}{% if not loop.first %},{% endif %}\'{{ item }}\'{% endfor %}$2',$report->raw_query);

            //allow {(macro)} instead of {% for item in macro %}{% if not item.first %},{% endif %}{{ item.value }}{% endfor %}
            //this is shorthand for quoted, comma separated list
            $report->raw_query = preg_replace('/([^\{])\{\('.$key.'\)\}([^\}])/','$1{% for item in '.$key.' %}{% if not loop.first %},{% endif %}(\'{{ item }}\'){% endfor %}$2',$report->raw_query);
        }
        //macros sortcuts for non-arrays
        else {
            //allow {macro} instead of {{macro}} for legacy support
            $report->raw_query = preg_replace('/([^\{])(\{'.$key.'+\})([^\}])/','$1{$2}$3',$report->raw_query);
        }
    }

    //if there are any included reports, add the report sql to the top
    if(isset($report->options['Includes'])) {
        $included_sql = '';
        foreach($report->options['Includes'] as &$included_report) {
            $included_sql .= trim($included_report->raw_query)."\n";
        }

        $report->raw_query = $included_sql . $report->raw_query;
    }

    //set a formatted query here for debugging.  It will be overwritten below after macros are substituted.
    $report->options['Query_Formatted'] = SqlFormatter::format($report->raw_query);
}

public static function openConnection(&$report) {
    if(isset($report->conn)) return;

    $environments = PhpReports::$config['environments'];
    $config = $environments[$report->options['Environment']][$report->options['Database']];

    //the default is to use a user with read only privileges
    $username = isset($config['user'])?$config['user']:NULL;
    $password = isset($config['pass'])?$config['pass']:NULL;
    $host = $config['host'];
    $Database = $config['Database'];
    $connectionInfo = $config['connectionInfo'];

    //if the report requires read/write privileges
    if(isset($report->options['access']) && $report->options['access']==='rw') {
        if(isset($config['user_rw'])) $username = $config['user_rw'];
        if(isset($config['pass_rw'])) $password = $config['pass_rw'];
        if(isset($config['host_rw'])) $host = $config['host_rw'];
    }

    if(!($report->conn = sqlsrv_connect($host, $connectionInfo))) {
        throw new Exception('Could not connect to sqlsrv: '.print_r(sqlsrv_errors(), true));
    }

    if(isset($config['database'])) {
        print_r( $config);
        if(!mssql_select_db($config['database'],$report->conn)) {
            throw new Exception('Could not select sqlsrv database: '.print_r(sqlsrv_errors(),true).print_r($report->conn,true));
        }
    }
}

public static function closeConnection(&$report) {
    if(!isset($report->conn)) return;
    sqlsrv_close($report->conn);
    unset($report->conn);
}

public static function getVariableOptions($params, &$report) {
    $query = 'SELECT DISTINCT '.$params['column'].' FROM '.$params['table'];

    if(isset($params['where'])) {
        $query .= ' WHERE '.$params['where'];
    }

    if(isset($params['order']) && in_array($params['order'], array('ASC', 'DESC')) ) {
        $query .= ' ORDER BY '.$params['column'].' '.$params['order'];
    }

    $result = sqlsrv_query($report->conn, $query);

    if(!$result) {
        throw new Exception("Unable to get variable options: ".print_r(sqlsrv_errors(), true));
    }

    if(!$result) {
            $errs='';
            if( ($errors = sqlsrv_errors() ) != null) {
            foreach( $errors as $error ) {
        $errs .= "SQLSTATE: ".$error[ 'SQLSTATE']; //."<br />";
        $errs .= " Code: ".$error[ 'code']."<br />";
        $errs .= "message: ".$error[ 'message']."<br />";
            }
        }
        throw new Exception("Unable to get variable options: ".$errs);
    }

    $options = array();

    if(isset($params['all'])) $options[] = 'ALL';

    while($row = sqlsrv_fetch_array($result,SQLSRV_FETCH_ASSOC)) {
        $options[] = $row[$params['column']];
    }

    return $options;
}

public static function run(&$report) {      
    $macros = $report->macros;
    foreach($macros as $key=>$value) {
        if(is_array($value)) {
            $first = true;
            foreach($value as $key2=>$value2) {
                //$value[$key2] = sqlsrv_real_escape_string(trim($value2));
                $value[$key2] = $value2;
                $first = false;
            }
            $macros[$key] = $value;
        }
        else {
            //$macros[$key] = sqlsrv_real_escape_string($value);
            $macros[$key] = $value;
        }

        if($value === 'ALL') $macros[$key.'_all'] = true;
    }

    //add the config and environment settings as macros
    $macros['config'] = PhpReports::$config;
    $macros['environment'] = PhpReports::$config['environments'][$report->options['Environment']];

    //expand macros in query
    $sql = PhpReports::render($report->raw_query,$macros);

    $report->options['Query'] = $sql;

    $report->options['Query_Formatted'] = SqlFormatter::format($sql);

    //split into individual queries and run each one, saving the last result        
    $queries = SqlFormatter::splitQuery($sql);

    $datasets = array();

    $explicit_datasets = preg_match('/--\s+@dataset(\s*=\s*|\s+)true/',$sql);

    foreach($queries as $i=>$query) {
        $is_last = $i === count($queries)-1;

        //skip empty queries
        $query = trim($query);
        if(!$query) continue;

        $result = sqlsrv_query($report->conn,$query);
        if(!$result) {
               $errs='';
               if( ($errors = sqlsrv_errors() ) != null) {
                foreach( $errors as $error ) {
            $errs .= "SQLSTATE: ".$error[ 'SQLSTATE']; //."<br />";
            $errs .= " Code: ".$error[ 'code']."<br />";
            $errs .= "message: ".$error[ 'message']."<br />";
                }
            }
            throw new Exception("Query failed: ".$errs);
        }

        //if this query had an assert=empty flag and returned results, throw error
        if(preg_match('/^--[\s+]assert[\s]*=[\s]*empty[\s]*\n/',$query)) {
            if(sqlsrv_fetch_array($result,SQLSRV_FETCH_ASSOC))  throw new Exception("Assert failed.  Query did not return empty results.");
        }

        // If this query should be included as a dataset
        if((!$explicit_datasets && $is_last) || preg_match('/--\s+@dataset(\s*=\s*|\s+)true/',$query)) {
            $dataset = array('rows'=>array());

            while($row = sqlsrv_fetch_array($result,SQLSRV_FETCH_ASSOC)) {
                $dataset['rows'][] = $row;
            }

            // Get dataset title if it has one
            if(preg_match('/--\s+@title(\s*=\s*|\s+)(.*)/',$query,$matches)) {
                $dataset['title'] = $matches[2];
            }

            $datasets[] = $dataset;
        }
    }

    return $datasets;
}
}