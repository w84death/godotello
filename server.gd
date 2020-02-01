extends Control

var TELLO_IP = "192.168.10.1"
var TELLO_PORT = 8889
var PORT_SERVER = 9000
var socketUDP = PacketPeerUDP.new()
var ffplay_pid = null
var distance = 20
var distance_deg = 45
var speed = 10
var IS_OK = false

func _ready():
	disable_buttons()
	pass

func log_event(event):
	$main/controlls/log/txt_log.add_text(event + "\n")
	
func _process(delta):   
	if socketUDP.get_available_packet_count() > 0:
		var array_bytes = socketUDP.get_packet()
		var answer = array_bytes.get_string_from_ascii()
		if answer == 'ok':
			answer = "confirms!"
			IS_OK = true
		log_event("Tello: " + answer )

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
	enable_command()

func disable_buttons():
	$info.hide()
	$main/controlls/nav_left.hide()
	$main/controlls/nav_right.hide()
	$main/sliders.hide()
	
func enable_command():
	$main/system/btn_command.disabled = false
	
func enable_buttons():
	if !IS_OK:
		return
	
	$main/system/btn_command.disabled = true
	for btn in $main/system.get_children():
		btn.disabled = false
	for btn in $main/auto.get_children():
		btn.disabled = false
	$info.show()
	$main/controlls/nav_left.show()
	$main/controlls/nav_right.show()
	$main/sliders.show()
	$main/system/btn_start_server.disabled = true

func _exit_tree():
	socketUDP.close()

func _on_btn_start_server_button_down():
	start_server()
	$timer.connect("timeout", self, "enable_buttons") 
	$timer.set_wait_time(1)

func _on_btn_command_button_down():
	IS_OK = false
	send_command('command')
	$timer.start()

func _on_btn_streamon_button_down():
	send_command('streamon')

func _on_btn_show_stream_button_down():
	ffplay_pid = OS.execute("bin/ffplay",["-probesize 32", "-i udp://@:11111", "-framerate 30" ], true)

func _on_btn_takeoff_button_down():
	send_command('takeoff')

func _on_btn_land_button_down():
	send_command('land')

func _on_btn_up_button_down():
	send_command('up ' + str(distance))

func _on_btn_ccw_button_down():
	send_command('ccw ' + str(distance_deg))

func _on_btn_cw_button_down():
	send_command('cw ' + str(distance_deg))

func _on_btn_down_button_down():
	send_command('down ' + str(distance))

func _on_btn_forward_button_down():
	send_command('forward ' + str(distance))

func _on_btn_left_button_down():
	send_command('left ' + str(distance))

func _on_btn_right_button_down():
	send_command('right ' + str(distance))

func _on_btn_back_button_down():
	send_command('back ' + str(distance))


func _on_sli_distance_value_changed(value):
	distance = value
	$main/sliders/distance/txt_distance.set_text(str(distance) + ' cm')


func _on_btn_quit_button_down():
	get_tree().quit()


func _on_sli_distance_deg_value_changed(value):
	distance_deg = value
	$main/sliders/distance_deg/txt_distance_deg.set_text(str(distance_deg) + ' degress')


func _on_sli_speed_value_changed(value):
	speed = value
	$main/sliders/speed/txt_speed.set_text(str(speed) + ' cm/s')
	send_command('speed ' + str(speed))


func _on_btn_stop_button_down():
	send_command('stop')


func _on_btn_send_cmd_pressed():
	var cmd = $main/controlls/log/input_line/cmd
	if cmd.text.length() > 0:
		send_command(str(cmd.text))
		cmd.text = ''
		cmd.grab_focus()


func _on_cmd_gui_input(event):
	print(event.get)
