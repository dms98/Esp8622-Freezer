<?php
$email_from = "email@" . $_SERVER[HTTP_HOST];  
$nome_para = "Qualquer um"; 
$email = "your-email@gmail.com"; 
$ip = $_SERVER["REMOTE_ADDR"];
$hora_servidor = date("d/m/Y H:i:s");
$assunto = "Aviso de problema na temperatura do Frezer";

$par_par = $_REQUEST["par"];
$par_envia = $_REQUEST["envia"];
$par_envia = strtoupper($par_envia);
$par_go = $_GET["go"];
$par_op = $_REQUEST["op"]; // operação
$par_op = strtoupper($par_op);
$par_message = $_REQUEST["message"];

$post = file_get_contents('php://input'); // pega o body enviado???
 
$quebra_linha="\r\n";
//$quebra_linha="\n";
 
echo "<HR>" . $post . "<HR>";


$headers = "MIME-Version: 1.0" . $quebra_linha . ""; 
$headers .= "Content-type: text/html; charset=iso-8859-1" . $quebra_linha . ""; 
$headers .= "From: $email_from " . $quebra_linha . ""; 
$headers .= "Return-Path: $email_from " . $quebra_linha . ""; 


$mensagem = "Isto é um teste de mensagem <BR>";
$mensagem.= "<B>TEMPERATURA COM PROBLEMA</B><BR>";
$mensagem.= "Message: " . $par_message . "<BR>";
$mensagem.= "Body: " . $post . "<BR>";

if ($par_op="ALTATEMPERATURA") { 
	// recebeu dados de temperatura
	$mensagem = "<H1> ATENÇÃO: *----* Alta Temperatura *-----* </H1> <BR>";
	$mensagem.= "<B>Temperatura do frezzer ou congelador com problemas!!!</B><BR>";
	$mensagem.= "<HR> Message: " . $par_message . "<HR><BR>";
}


echo "nome_para: " . $nome_para ."<BR>";
echo "nome_from: " . $nome_from ."<BR>";
echo "email_to: " . $email ."<BR>";
echo "hora servidor: " . $hora_servidor . " - IP Servidor: " . $ip . "<BR>";
echo "message: " . $par_message . "<BR>";
echo "envia? " . $par_envia . "<BR>";
echo "par_op: " . $par_op . "<BR>";
echo "messagem: " . $mensagem . "<BR>";

if ($par_envia="SIM") { 
//envia o email sem anexo 
	mail($email,$assunto,$mensagem, $headers, "-r".$email_from); 

	if ($par_go!="") { 
		$vai_para = "Location: " . $vai[$par_go];
		header($vai_para);
		die;
		}
} else { 
	echo "Mensagem não enviada, set envia";
}
	


if ($par_go=="") {
	//header("Location: http://www.mp.go.gov.br");
	echo 'par_par: ' . $par_par . '<br>';
	echo 'get-par: ' . $_GET["par"] . '<br>';
	echo 'par_go: ' . $par_go . '<br>';
	echo 'get_go: ' . $_GET["go"] . '<br>';
	echo 'par_message: ' . $_GET["message"] . '<br>';
	echo '<HR>vai para: ' . $vai[$par_go] . '<BR>';
	
	if ($par_par=="lista") { 
		foreach($vai as $x => $x_value) {
			echo "Key=" . $x . ", Value=" . $x_value;
			echo "<br>";
		}
	}
}


?>