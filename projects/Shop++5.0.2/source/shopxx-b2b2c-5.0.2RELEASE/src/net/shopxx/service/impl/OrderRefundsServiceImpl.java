/*
 * Copyright 2005-2017 shopxx.net. All rights reserved.
 * Support: http://www.shopxx.net
 * License: http://www.shopxx.net/license
 */
package net.shopxx.service.impl;

import javax.inject.Inject;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.Assert;

import net.shopxx.dao.SnDao;
import net.shopxx.entity.OrderRefunds;
import net.shopxx.entity.Sn;
import net.shopxx.service.OrderRefundsService;

/**
 * Service - 订单退款
 * 
 * @author SHOP++ Team
 * @version 5.0
 */
@Service
public class OrderRefundsServiceImpl extends BaseServiceImpl<OrderRefunds, Long> implements OrderRefundsService {

	@Inject
	private SnDao snDao;

	@Override
	@Transactional
	public OrderRefunds save(OrderRefunds orderRefunds) {
		Assert.notNull(orderRefunds);

		orderRefunds.setSn(snDao.generate(Sn.Type.orderRefunds));

		return super.save(orderRefunds);
	}

}