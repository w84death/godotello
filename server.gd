extends Control

var TELLO_IP = "192.168.10.1"
var TELLO_PORT = 8889
var PORT_SERVER = 9000
var socketUDP = PacketPeerUDP.new()
var ffplay_pid = null;

func _ready():
	$main/controlls.hide()
	pass;

func log_event(event):
	$main/controlls/log/txt_log.add_text(event + "\n")
	
func _process(delta):   
	if socketUDP.get_available_packet_count() > 0:
		var array_bytes = socketUDP.get_packet()
		log_event("Tello: " + array_bytes.get_string_from_ascii())

func send_command(cmd):
	log_event("Cockpit: " + cmd)
	socketUDP.set_dest_address(TELLO_IP, TELLO_PORT)
	var pac = cmd.to_utf8()
	socketUDP.put_packet(pac)

func start_server():
	if (socketUDP.listen(PORT_SERVER) != OK):
		log_event("Cockpit: Error listening on port: " + str(PORT_SERVER))
	else:
		log_event("Cockpit: Listening on port: " + str(PORT_SERVER))
		enable_buttons()

func enable_buttons():
	for btn in $main/system.get_children():
		btn.disabled = false
	for btn in $main/auto.get_children():
		btn.disabled = false
	$main/controlls.show()
	$main/system/btn_start_server.disabled = true

func _exit_tree():
	socketUDP.close()


func _on_btn_start_server_button_down():
	start_server()
	
func _on_btn_command_button_down():
	send_command('command');

func _on_btn_streamon_button_down():
	send_command('streamon');

func _on_btn_show_stream_button_down():
	ffplay_pid = OS.execute("bin/ffplay",["-probesize 32", "-i udp://@:11111", "-framerate 30" ], true)

func _on_btn_takeoff_button_down():
	send_command('takeoff');

func _on_btn_land_button_down():
	send_command('land');

func _on_btn_up_button_down():
	send_command('up');

func _on_btn_ccw_button_down():
	send_command('ccw');

func _on_btn_cw_button_down():
	send_command('cw');

func _on_btn_down_button_down():
	send_command('down');

func _on_btn_forward_button_down():
	send_command('forward');

func _on_btn_left_button_down():
	send_command('left');

func _on_btn_right_button_down():
	send_command('right');

func _on_btn_back_button_down():
	send_command('back');
