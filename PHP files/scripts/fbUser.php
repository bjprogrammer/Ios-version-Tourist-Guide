<?php

require("../db/Conn.php");
require("../db/MySQLDAO.php");


$returnValue = array();

if(empty($_REQUEST["userEmail"])
        || empty($_REQUEST["userFirstName"])
        || empty($_REQUEST["userLastName"]))
{
    $returnValue["status"]="400";
    $returnValue["message"]="Missing required information";
    echo json_encode($returnValue);
    return;
}

$userEmail = htmlentities($_REQUEST["userEmail"]);
$userFirstName = htmlentities($_REQUEST["userFirstName"]);
$userLastName = htmlentities($_REQUEST["userLastName"]);
$fbid = htmlentities($_REQUEST["userID"]);


$dbhost = Conn::$dbhost;
$dbuser = Conn::$dbuser;
$dbpassword = Conn::$dbpassword;
$dbname = Conn::$dbname;


$dao = new MySQLDAO($dbhost, $dbuser, $dbpassword, $dbname);
$dao->openConnection();

// Check if user with provided username is available
$userDetails = $dao->getfbUserDetails($userEmail);
if(!empty($userDetails))
{
    $returnValue["status"]="400";
    $returnValue["message"]="Successfully registered new user"; 
    $returnValue["userId"] = $userDetails["user_id"];
    $returnValue["userFirstName"] = $userDetails["first_name"];
    $returnValue["userLastName"] = $userDetails["last_name"];
    $returnValue["userEmail"] = $userDetails["email"]; 
    echo json_encode($returnValue);
    return;
}

// Register new user
$result =$dao->fbUser($userEmail, $userFirstName, $userLastName, $fbid);

if($result)
{
    $userDetails = $dao->getfbUserDetails($userEmail);
    $returnValue["status"]="200";
    $returnValue["message"]="Successfully registered new user";    
    $returnValue["userId"] = $userDetails["user_id"];
    $returnValue["userFirstName"] = $userDetails["first_name"];
    $returnValue["userLastName"] = $userDetails["last_name"];
    $returnValue["userEmail"] = $userDetails["email"]; 
    
} else {   
    $returnValue["status"]="400";
    $returnValue["message"]="Could not register user with provided information"; 
}

$dao->closeConnection();

echo json_encode($returnValue);


?>