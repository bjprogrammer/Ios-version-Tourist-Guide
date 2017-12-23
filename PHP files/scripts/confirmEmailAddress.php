<?php
require("../db/MySQLDAO.php");
require("../db/Conn.php");
$dbhost = Conn::$dbhost;
$dbuser = Conn::$dbuser;
$dbpassword = Conn::$dbpassword;
$dbname = Conn::$dbname;

$emailToken = htmlentities($_GET["token"]);
if(empty($emailToken))
{
    echo "Missing required parameter";
    return;
}

$dao = new MySQLDAO($dbhost, $dbuser, $dbpassword, $dbname);
$dao->openConnection();

$user_id = $dao->getUserIdWithToken($emailToken);

if(empty($user_id))
{
    echo "User with this email token is not found";
    return;
}

$result = $dao->setEmailConfirmedStatus(1, $user_id);
if($result)
{ 
  $dao->deleteUsedToken($emailToken);  
  echo "Thank you! Your email is now confirmed!"; 
}

$dao->closeConnection();

?>