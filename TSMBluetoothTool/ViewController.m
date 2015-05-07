//
//  ViewController.m
//  TSMBluetoothTool
//
//  Created by PBOC CS on 15/4/2.
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//  基础页面，检测蓝牙设备

#import "ViewController.h"
#import "LVBlutToothViewcontroller.h"
#import <CoreBluetooth/CoreBluetooth.h>



@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CBCentralManager *manager;

@property (nonatomic, strong) CBPeripheral *peripheral;
/**
 *  外设数组
 */
@property (nonatomic, strong) NSMutableArray *peripherals;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation ViewController

- (NSMutableArray *)peripherals {
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CBCentralManager *manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.manager = manager;
    
    
}

// 扫描
- (IBAction)startScan {
    [self.peripherals removeAllObjects];
    [self.tableView reloadData];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    [self.manager scanForPeripheralsWithServices:nil options:dict];
}

- (IBAction)stopScan {
    [self.manager stopScan];
}

- (IBAction)connect:(id)sender {
    
    for (CBPeripheral *peripheral in self.peripherals) {
        //BroadthinkingBJ  LinkSim_12345678901 Hierstar Bluetooth Card
        if ([peripheral.name isEqualToString:@"Hierstar Bluetooth Card"]) {
            peripheral.delegate =self;
            NSDictionary *option = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnConnectionKey];
            [self.manager connectPeripheral:peripheral options:option];
        }
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    CBPeripheral *peripheral = self.peripherals[indexPath.row];
    self.peripheral = peripheral;
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = peripheral.identifier.UUIDString;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 连接外设
    CBPeripheral *peripheral = self.peripherals[indexPath.row];
    self.peripheral = peripheral;
    NSDictionary *option = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnConnectionKey];
    [self.manager connectPeripheral:peripheral options:option];
}



/**
 *  中央管理器的状态改变了 代开蓝牙显示 CBCentralManagerStatePoweredOn 关闭蓝牙状态 CBCentralManagerStatePoweredOff
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"1 === %zd", central.state);
}


/*!
 *  @method centralManager:willRestoreState:
 *
 *  @param central      The central manager providing this information.
 *  @param dict			A dictionary containing information about <i>central</i> that was preserved by the system at the time the app was terminated.
 *
 *  @discussion			For apps that opt-in to state preservation and restoration, this is the first method invoked when your app is relaunched into
 *						the background to complete some Bluetooth-related task. Use this method to synchronize your app's state with the state of the
 *						Bluetooth system.
 *
 *  @seealso            CBCentralManagerRestoredStatePeripheralsKey;
 *  @seealso            CBCentralManagerRestoredStateScanServicesKey;
 *  @seealso            CBCentralManagerRestoredStateScanOptionsKey;
 *
 */
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    NSLog(@"2 === %@", dict);
}

/*!
 *  @method centralManager:didRetrievePeripherals:
 *
 *  @param central      The central manager providing this information.
 *  @param peripherals  A list of <code>CBPeripheral</code> objects.
 *
 *  @discussion         This method returns the result of a {@link retrievePeripherals} call, with the peripheral(s) that the central manager was
 *                      able to match to the provided UUID(s).
 *
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    NSLog(@"3 === %@", peripherals);
}

/*!
 *  @method centralManager:didRetrieveConnectedPeripherals:
 *
 *  @param central      The central manager providing this information.
 *  @param peripherals  A list of <code>CBPeripheral</code> objects representing all peripherals currently connected to the system.
 *
 *  @discussion         This method returns the result of a {@link retrieveConnectedPeripherals} call.
 *
 */
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    NSLog(@"4 === %@", peripherals);
}

/*!
 *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 *
 *  @param central              The central manager providing this update.
 *  @param peripheral           A <code>CBPeripheral</code> object.
 *  @param advertisementData    A dictionary containing any advertisement and scan response data.
 *  @param RSSI                 The current RSSI of <i>peripheral</i>, in dBm. A value of <code>127</code> is reserved and indicates the RSSI
 *								was not available.
 *
 *  @discussion                 This method is invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>. A discovered peripheral must
 *                              be retained in order to use it; otherwise, it is assumed to not be of interest and will be cleaned up by the central manager. For
 *                              a list of <i>advertisementData</i> keys, see {@link CBAdvertisementDataLocalNameKey} and other similar constants.
 *
 *  @seealso                    CBAdvertisementData.h
 *
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"5 === %@", peripheral);
    
    if (![self.peripherals containsObject:peripheral]) {
        [self.peripherals addObject:peripheral];
        [self.tableView reloadData];
    }
}

/*!
 *  @method centralManager:didConnectPeripheral:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has connected.
 *
 *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has succeeded.
 *
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    // 连接外设成功跳转显示设备信息控制器
    LVBlutToothViewcontroller *infoVc = [[LVBlutToothViewcontroller alloc] init];
    infoVc.peripheral = peripheral;
    infoVc.title = peripheral.name;
    [self.navigationController pushViewController:infoVc animated:YES];
}

/*!
 *  @method centralManager:didFailToConnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has failed to connect.
 *  @param error        The cause of the failure.
 *
 *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has failed to complete. As connection attempts do not
 *                      timeout, the failure of a connection is atypical and usually indicative of a transient issue.
 *
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"%@", error);
    }else {
        NSLog(@"连接成功");
    }
}

/*!
 *  @method centralManager:didDisconnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has disconnected.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method is invoked upon the disconnection of a peripheral that was connected by {@link connectPeripheral:options:}. If the disconnection
 *                      was not initiated by {@link cancelPeripheralConnection}, the cause will be detailed in the <i>error</i> parameter. Once this method has been
 *                      called, no more methods will be invoked on <i>peripheral</i>'s <code>CBPeripheralDelegate</code>.
 *
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"7 ===失去连接 %@", peripheral);
    
}

@end